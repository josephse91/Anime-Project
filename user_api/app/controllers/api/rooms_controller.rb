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
        user = client_user
        return if !user

        room_name = rooms_params[:room_id]
        
        @room = Room.new(
            room_name: room_name
        )

        privacy = rooms_params[:private_room]
        privacy ? @room.private_room = privacy : nil

        @room.users[user.username] = TIME_INPUT
        @room.admin["admin_users"][user.username] = TIME_INPUT

        if @room.invalid?
            render json: {status: "failed", error: @room.errors.objects.first.full_message}
            return
        end

        @room.save

        user.rooms[room_name] = TIME_INPUT
        user.save

        render json: {
            status: "complete", 
            room: @room,
            action: "member added",
            user: user,
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
        # The following line is something that should run nightly and autonomously 
        clean_expired_keys(@room)
    end

    def update
        @room = find_room
        return if !@room

        user = client_user
        return if !user

        render_obj = {
            status: "complete", 
            room: @room
        }

        current_username = user.username
        room_name = @room.room_name

        notifications = []

        room_action = rooms_params[:room_action]
        request = rooms_params[:request]
        request_user = find_request_obj
        return if request && !request_user
        
        # Simple User self addition for Public Rooms
        foreign_requester = !room_includes_user?(@room,current_username)
        room_admin_check = @room.admin["admin_users"][current_username]

        if request && !foreign_requester && !room_admin_check
            render json: {status: "failed", errors: "This user is already within the room"}
            return
        end

        if request == current_username && !@room.private_room && foreign_requester
            @room.users[request] = TIME_INPUT
            @room.save
            request_user.rooms[room_name] = TIME_INPUT
            request_user.save

            render_obj[:user] = request_user
            render_obj[:action] = "member added"
            render_obj[:room] = @room

            render json: render_obj
            return
        end

        # --------------------------------------------------------
        # Foreign user request a private non group_admin room
        
         group_admins = @room.admin["admin_users"].keys

        if !@room.admin["group_admin"] && request == current_username
            @room.pending_approval[current_username] = TIME_INPUT
            @room.save
            
            request_to_admins(notifications,@room,request)

            render_obj[:notifications] = notifications
            render_obj[:requester] = foreign_requester
            render_obj[:admins] = group_admins
            render_obj[:room] = @room

            render json: render_obj
            return
        end


        #--------------------------------------------------------
        # Foreign user enters a submitted key
        submitted_key = rooms_params[:submitted_key]
        valid_key_check = submitted_key ? @room.entry_keys[:submitted_key] : nil
        valid_request = rooms_params[:submitted_key] && current_username == request
        room_keys = @room.entry_keys
        group_admin_check = @room.admin["group_admin"] == true

        #byebug
        if !submitted_key && request && group_admin_check
            render json: {status: "failed", error: "Key Needed to Enter room"}
            return
        end

        if valid_request && @room.users[user]
            render json: {status: "failed", error: "User is already within room"}
            return
        end

        if submitted_key && !valid_request && group_admin_check
            render json: {status: "failed", error: "For this room, you must receive a key. Ask a member to generate key"}
            return
        end

        if submitted_key && valid_request && !group_admin_check
            render json: {status: "failed", error: "For this room, you must receive admin approval"}
            return
        end

        if submitted_key && valid_request && group_admin_check
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

            @room.users[current_username] = TIME_INPUT
            user.rooms[room_name] = TIME_INPUT

            @room.save
            user.save

            render_obj = {
                status: "complete", 
                message: "Key has been successfully submitted to Room: #{room_name}",
                action: "member added",
                user: user,
                room: @room
            }

            render json: render_obj
            return
        end
        #-------------------------------------------------------------------
        # Member actions
        member_check = room_includes_user?(@room,current_username,true)
        return if !member_check

        generate_key = rooms_params[:make_entry_key]
        
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

        member_leave = room_action == "leave room"

        if member_leave 
            remove_member = remove_member(user,@room,room_admin_check)
            return if !remove_member

            render_obj = {status: "complete", user: user, room: @room, action: "member removed"}

            if remove_member[:message]
                render_obj[:message] = remove_member[:message]
            end
            render json: render_obj
            return
        end

        # -----------------------------------------------------------------------
        # Group Admin procedures
        target_member = rooms_params[:user_id]

        if target_member
            target_member_obj = find_user
            return if !target_member_obj

            target_member_username = target_member_obj.username
            target_member_check = room_includes_user?(@room,target_member_username,true)
            return if !member_check

            target_member_admin_check = @room.admin["admin_users"][target_member_username] != nil
        end

        if !room_admin_check
            render json: {status: "failed", error: "must be an admin to make change"}
            return
        end

        if room_action == "reject pending"
            @room.pending_approval.delete(request)
            @room.save

            render json: {status: "complete", room: @room}
            return
        end

        # Admin remove user
        user_remove = rooms_params[:room_action] == "remove user"

        removable_user = user_remove && target_member_username != current_username
        valid_remove = removable_user && !target_member_admin_check

        if removable_user && !valid_remove
            render json: {status: "failed", errors: "Admin members cannot be removed"}
            return
        end
        

        if valid_remove
            remove_member = remove_member(target_member_obj,@room,room_admin_check)
            return if !remove_member

            render json: {status: "complete", user: target_member_obj, room: @room, action: "member removed"}
            return
        end
        
        # Admin change name
        if rooms_params[:room_name]
            if group_admin_check || room_admin_check
                @room.room_name = rooms_params[:room_name] || room_name
                @room.save
            else
                render json: {status: "failed", error: "Not authorized user"}
                return
            end
        end

        member_request = request && !@room.admin["group_admin"]
        # Group admin can only approve users that have sent a request. (Pending)
        pending_user = @room.pending_approval[request]

        if !foreign_requester && !room_admin_check
            render json: {status: "failed", errors: "User has already been added to the room"}
            return
        end

        if  member_request && room_admin_check && pending_user
            @room.users[request] = TIME_INPUT
            request_user.rooms[room_name] = TIME_INPUT
            request_user.save

            render_obj[:action] = "member added"
            render_obj[:user] = request_user

            @room.pending_approval.delete(request)
            clear_admin_request(@room,request)
            @room.save
            add_notification(notifications,@room,request_user,nil, "Accepted request to join")
        elsif member_request && !room_admin_check && !@room.pending_approval[request]
            request_user.requests["room"][@room.room_name] = current_username
            request_user.save
            add_notification(notifications,@room,request_user,user,"Requested to Join")
        end

        privacy = rooms_params[:private_room]
        
        if privacy
            @room.private_room = privacy
            @room.save
        end

        add_admin = rooms_params[:room_action] == "add admin"
        remove_admin = rooms_params[:room_action] == "remove admin"

        if add_admin 
            @room.admin["admin_users"][target_member_username] = TIME_INPUT
            @room.save
        end

        if remove_admin && @room.admin["admin_users"][target_member_username]
            render json: {status: "failed", errors: "Admins status cannot be taken away by others"}
            return
        elsif remove_admin && user 
            @room.admin["admin_users"].delete(current_username)
            @room.save
        end

        if request
            render_obj[:notifications] = notifications
        end

        render_obj[:room] = @room
        render json: render_obj
    end

    def destroy
        @room = find_room
        return if !@room

        user = client_user
        return if !user

        if @room.users.length > 1
            render json: {status: "failed", error: "There are still users within the Room"}
            return
        end

        if !@room.users[user.username]
            render json: {status: "failed", error: "User must be within Room"}
            return
        end

        delete_shows = @room.shows.keys
        delete_shows_obj = Review.where(show: delete_shows)
        delete_room = @room
        deleted_room_name = @room.room_name
        

        delete_forums_and_comments(deleted_room_name)

        render json: {
            status: "complete",
            user: user, 
            room: deleted_room_name,
            remove_shows: delete_shows_obj, 
            action: "delete room",
        }

        @room.destroy
    end

    def rooms_params
        params.permit(:id,:pending_approval,:search,:current_user,:request,:user_remove,:make_entry_key,:submitted_key,:user_id, :room_id, :room_action, :private_room)
    end

    def client_user
        user = current_user
        if !user
            render json: {status: "failed", error: "User not signed in"}
        end
        user
    end

    def find_user
        user_input = rooms_params[:user_id]
        user = User.find_by(username: user_input)
        if !user
            render json: {status: "failed", error: "User could not be found"}
        end
        user
    end

    def find_request_obj
        user_input = rooms_params[:request]
        user = User.find_by(username: user_input)
        if !user && user_input
            render json: {status: "failed", error: "User could not be found"}
        end
        user
    end

    def room_includes_user?(room,username,member_action = false)
        member_check = room.users[username] != nil
        if !member_check && member_action
            render json: {status: "failed", error: "must be a member of room"}
            return
        end
        member_check
    end

    def find_room
        room_input = rooms_params[:id] || rooms_params[:room_id]
        room = Room.where(room_name: room_input).where(retired: false).take

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

    def remove_member(member_obj,room_obj,room_admin_check)
        output = {}
        member_username = member_obj.username
        room_name = room_obj.room_name

        # if the admin member is the LAST admin in the group, you must switch the room admin type to group admin style if it isn't that

        group_admin_type = room_obj.admin["group_admin"]
        admin_member_count = room_obj.admin["admin_users"].keys.length

        group_admin_switch = !group_admin_type && room_admin_check && admin_member_count == 1

        if group_admin_switch
            room_obj.admin["group_admin"] = true
            output[:message] = "Admin switched to Group Admin"
        end

        #delete the admin from room
        if room_admin_check
            room_obj.admin["admin_users"].delete(member_username)
        end

        #delete member        
        member_obj.rooms.delete(room_name)
        room_obj.users.delete(member_username)

        if member_obj.invalid?
            render json: {status: "failed", error: member_obj.errors.objects.first.full_message}
            return
        end

        if room_obj.invalid?
            render json: {status: "failed", error: room_obj.errors.objects.first.full_message}
            return
        end

        member_obj.save
        room_obj.save
        
        output[:member] = member_obj
        output[:room] = room_obj
        output
    end

    def request_to_admins(notifications,room,requester)
        room_admin_check = room.admin["admin_users"].keys

        room_admin_check.each do |admin_names|
            admin_user = User.find_by(username: admin_names)
            admin_user.requests["roomAuth"][room.room_name] = [requester,TIME_INPUT]
            admin_user.save
            add_notification(notifications,room,admin_user,requester,"Requested to join")
        end

        room_admin_check
    end

    def clear_admin_request(room,admitted_user)
        room_admin_check = room.admin["admin_users"].keys

        room_admin_check.each do |admin|
            admin_user = User.find_by(username: admin)
            admin_user.requests["roomAuth"].delete(admitted_user)
            admin_user.save
        end
    end

    def add_notification(notifications,room,recipient,user,request_type = "Accept")
        action_user = user ? user : room.room_name
        data = {
            id: room.id,
            recipient: recipient.username,
            action: request_type,
            action_user: action_user,
            target_item: "Room",
            room: room.room_name
        }
        
        notifications.push(data)
        notifications
    end
end