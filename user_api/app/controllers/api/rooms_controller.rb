class Api::RoomsController < ApplicationController
    NOW = Time.new
    TIME_INPUT = "#{NOW.month}-#{NOW.day}-#{NOW.year}"
    
    def index
        rooms_search = rooms_params[:search] ? "%#{rooms_params[:search]}%": nil

        if rooms_search
            rooms = Room.where(["room_name LIKE ?",rooms_search])
        else
            rooms = Room.all
        end

        render json: {status: "complete", rooms: rooms}
    end

    def create
        current_user = find_user
        return if !current_user
        
        @room = Room.new(
            room_name: rooms_params[:room_id]
        )

        privacy = rooms_params[:private_room]
        privacy ? @room.private_room = privacy : nil

        @room.users[current_user.username] = TIME_INPUT
        @room.admin["admin_users"][current_user.username] = TIME_INPUT

        if @room.invalid?
            render json: {status: "failed", error: @room.errors.objects.first.full_message}
            return
        end

        @room.save
        render json: {
            status: "complete", 
            room: @room,
            action: "member added",
            user: current_user,
        }
    end

    def add_user_reviews_to_room
        action = rooms_params[:room_action]
        user = find_user
        return if !user

        room = find_room
        return if !room

        edit_existing_shows = []
        add_new_show = []
        remove_shows = []

        reviews = Review.where(user: user.username)
        reviews.each do |review|
            if room.shows[review.show] && action == "member added"
                room.shows[review.show] += 1
                edit_existing_shows.push(review)
            elsif !room.shows[review.show] && action == "member added"
                room.shows[review.show] = 1
                add_new_show.push(review)
            elsif room.shows[review.show] == 1 && action == "member removed"
                room.shows.delete(review.show)
                remove_shows.push(review)
            elsif room.shows[review.show] > 1 && action == "member removed"
                room.shows[review.show] -= 1
                edit_existing_shows.push(review)
            end
        end

        if room.invalid?
            render json: {status: "failed", error: room.errors.objects.first.full_message}
            return
        end

        room.save
        render json: {
            status: "complete", 
            reviews: reviews, 
            room: room,
            action: action, 
            add_shows: add_new_show,
            edit_existing_shows: edit_existing_shows,
            remove_shows: remove_shows
        }

    end

    def show
        @room = find_room
        return if !@room

        render json: {status: "complete", room: @room}  
        clean_expired_keys(@room)
    end

    def update
        @room = find_room
        return if !@room

        user = find_user
        return if !user

        render_obj = {
            status: "complete", 
            room: @room
        }

        current_user = user.username
        room_name = @room.room_name

        notifications = []
        request = rooms_params[:request]
        request_user = User.find_by(username: request)
        if request && !request_user
            render json: {status: "failed", error: "User could not be found"}
            return
        end
        submitted_key = rooms_params[:submitted_key]
        user_remove = rooms_params[:user_remove]
        room_keys = @room.entry_keys
        group_admin = @room.admin["group_admin"]
        room_admins = @room.admin["admin_users"][current_user]

        if submitted_key
            if !room_keys[submitted_key]
                render json: {status: "failed", error: "Incorrect Entry Key"}
                clean_expired_keys(@room)
                return
            end

            if room_keys[submitted_key] < Time.now
                render json: {status: "failed", error: "Expiration Expired"}
                clean_expired_keys(@room)
                return
            end

            @room.users[current_user] = TIME_INPUT
            user.rooms[room_name] = TIME_INPUT

            @room.save
            user.save
            
            add_notification(notifications,@room,user)

            render_obj = {
                status: "complete", 
                message: "Key has been successfully submitted to Room: #{room_name}",
                action: "member added",
                user: user,
                notification: notifications,
                room: @room
            }

            render json: render_obj
            return
        end

        if request && request == current_user    
            if (group_admin && @room.pending_approval[request]) || !@room.private_room
                @room.users[request] = TIME_INPUT
                user.rooms[room_name] = TIME_INPUT
                user.save
                add_notification(notifications,@room,user)
            elsif group_admin && !@room.pending_approval[request]
                render json: {status: "failed", error: "For this room, you must receive a key. Ask a member to generate key"}
                return
            else
                @room.pending_approval[request] = TIME_INPUT
                request_to_admins(notifications,@room,request)
            end
            
            @room.save

            render_obj = {
                status: "complete", 
                room: @room,
                notifications: notifications
            }
            
            render_obj[:notifications] = notifications
            render json: render_obj
            return
        end

        if user_remove && user_remove == current_user
            user.rooms.delete(room_name)
            @room.users.delete(current_user)

            if user.invalid?
                render json: {status: "failed", error: user.errors.objects.first.full_message}
                return
            end

            if @room.invalid?
                render json: {status: "failed", error: @room.errors.objects.first.full_message}
                return
            end

            user.save
            @room.save

            render json: {status: "complete", user: user, room: @room, action: "member removed"}
            return
        end

        if !@room.users[current_user] 
            render json: {status: "failed", error: "Only users within room can update the room"}
            return
        end

        generate_key = rooms_params[:make_entry_key]
        pending_user = @room.pending_approval[request]

        if rooms_params[:room_name]
            if group_admin || room_admins
                @room.room_name = rooms_params[:room_name] || room_name
                @room.save
            else
                render json: {status: "failed", error: "Not authorized user"}
                return
            end
        end

        if user_remove
            if !room_admins && user_remove != current_user
                render json: {status: "failed", error: "Not authorized to remove user from room"}
                return
            end

            user.rooms.delete(room_name)
            @room.users.delete(current_user)

            user.save
            @room.save

            render json: {status: "complete", user: user, action: "member removed"}
            return
            # Logic needs to be included to change the rating total of each applicable show within the room
        end

        if generate_key
            key = Room.generate_entry_key
            @room.entry_keys[key] = Time.now.advance(days: 10).at_noon.getutc

            if !@room.valid?
                render json: {status: "failed", error: @room.errors.objects.first.full_message}
                return
            end

            @room.save
            render json: {status: "complete", key: key, room: @room}
            return
        end

        member_request = request && !submitted_key

        if  member_request && room_admins && @room.pending_approval[request]
            @room.users[request] = TIME_INPUT
            request_user.rooms[room_name] = TIME_INPUT
            request_user.save

            render_obj[:action] = "member added"
            render_obj[:user] = request_user

            @room.pending_approval.delete(request)
            clear_admin_request(@room,request)
            @room.save
            add_notification(notifications,@room,request_user, "Accepted request to join")
        elsif member_request && !room_admins && !@room.pending_approval[request]
            request_user.requests["room"][@room.room_name] = current_user
            request_user.save
            add_notification(notifications,@room,request_user,"Requested to Join")
        else
            render json: {status: "failed", error: "Only the authorized user can bring in users into the room"}
            return
        end

        privacy = rooms_params[:private_room]
        
        if privacy
            @room.private_room = privacy
            @room.save
        end

        render_obj = {
            status: "complete", 
            room: @room
        }

        if request
            render_obj[:notifications] = notifications
        end

        render json: render_obj
    end

    def destroy
        @room = find_room
        return if !@room

        user = find_user
        return if !user

        if @room.users.length > 1
            render json: {status: "failed", error: "There are still users within the Room"}
            return
        end

        if !@room.users[user.username]
            render json: {status: "failed", error: "User must be within Room"}
            return
        end

        deleted_room = @room.room_name
        @room.destroy

        delete_forums_and_comments(deleted_room)

        render json: {status: "complete", room: deleted_room}
    end

    def rooms_params
        params.permit(:id,:pending_approval,:search,:current_user,:request,:user_remove,:make_entry_key,:submitted_key,:user_id, :room_id, :room_action, :private_room)
    end

    def find_user
        user_input = rooms_params[:current_user] || rooms_params[:user_id]
        user = User.find_by(username: user_input)

        if !user
            render json: {status: "failed", error: "User could not be found"}
        end

        user
    end

    def find_room
        room_input = rooms_params[:id] || rooms_params[:room_id]
        room = Room.find_by(room_name: room_input)

        if !room
            render json: {status: "failed", error: "Room could not be found"}
        end

        room
    end

    def clean_expired_keys(room)
        deleted_keys = [];
        room.entry_keys.each do |key,val|
            expire_time = Time.parse(val)
            if expire_time < Time.now
                deleted_keys.push(key)
                room.entry_keys.delete(key)
            end
        end

        deleted_keys.length > 0 ? room.save : nil
        deleted_keys
    end

    def delete_forums_and_comments(room)
        forums = Forum.where(room_id: room)

        forums.each do |forum|
            forum_comments = ForumComment.where(forum_post: forum.id)
            forum_comments.delete_all

            forum.delete
        end

        forums
    end

    def request_to_admins(notifications,room,request)
        room_admins = room.admin["admin_users"].keys

        room_admins.each do |admin_names|
            admin_user = User.find_by(username: admin_names)
            admin_user.requests["roomAuth"][request] = TIME_INPUT
            admin_user.save
            add_notification(notifications,@room,admin_user,"Requested to join")
        end
    end

    def clear_admin_request(room,admitted_user)
        room_admins = room.admin["admin_users"].keys

        room_admins.each do |admin|
            admin_user = User.find_by(username: admin)
            admin_user.requests["roomAuth"].delete(admitted_user)
            admin_user.save
        end
    end

    def add_notification(notifications,room,user,request_type = "Accept")
        data = {
            id: room.id,
            recipient: user.username,
            action: request_type,
            action_user: room.room_name,
            target_item: "Room"
        }
        
        notifications.push(data)
        notifications
    end
end
