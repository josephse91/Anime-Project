class Api::RoomsController < ApplicationController
    NOW = Time.new
    TIME_INPUT = "#{NOW.month}/#{NOW.day}/#{NOW.year}"
    
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
        current_user = rooms_params[:current_user]
        
        @room = Room.new(
            room_name: rooms_params[:room_name]
        )

        if @room.valid?
            @room.users[current_user] = TIME_INPUT
            @room.admin["admin_users"][current_user] = TIME_INPUT
            @room.save
            render json: {status: "complete", room: @room}
        else
            render json: {status: "failed", error: @room.errors.objects.first.full_message}
        end
        
    end

    def show
        @room = Room.find_by(room_name: rooms_params[:id])

        if @room
            render json: {status: "complete", room: @room}
        else
            render json: {status: "failed", error: "Could not find room"}
        end
        
        clean_expired_keys(@room)
    end

    def update
        @room = find_room
        return if !@room

        user = find_user
        return if !user

        current_user = user.username
        room_name = @room.room_name

        request = rooms_params[:request]
        request_user = User.find_by(username: request)
        submitted_key = rooms_params[:submitted_key]
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

            render_obj = {
                status: "complete", 
                message: "Key has been successfully submitted to Room: #{room_name}",
                notification: current_user,
                room: @room
            }

            render json: render_obj
            return
        end

        if request && request == current_user
            @room.pending_approval[request] = TIME_INPUT
            !group_admin ? request_to_admins(@room,request) : @room.users[request] = TIME_INPUT
            @room.save

            !group_admin ? user.rooms[room_name] = TIME_INPUT : nil
            user.save

            render_obj = {
                status: "complete", 
                room: @room
            }

            if group_admin
                render_obj[:notification] = user.username
                render_obj[:message] = "You have been added to Room: #{room_name}"
            else
                render_obj[:notification] = @room.admin["admin_users"].keys
                render_obj[:message] = "Request has been sent to Room: #{room_name}"
            end

            render json: render_obj
            return
        end

        if !@room.users[current_user] 
            render json: {status: "failed", error: "Only users within room can update the room"}
            return
        end

        user_remove = rooms_params[:user_remove]
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

            # Logic needs to be included to change the rating total of each applicable show within the room
        end

        if request && !submitted_key
            if group_admin || room_admins
                @room.users[request] = TIME_INPUT
                request_user.rooms[room_name] = TIME_INPUT
                request_user.save

                pending_user ? @room.pending_approval.delete(request) : nil
                !group_admin ? clear_admin_request(@room,request) : nil
            else
                @room.pending_approval[request] = TIME_INPUT
                !group_admin ? request_to_admins(@room,request) : nil
            end
            @room.save
        end

        if generate_key
            key = Room.generate_entry_key
            @room.entry_keys[key] = Time.now.advance(days: 10).at_noon.getutc

            if !@room.valid?
                render json: {status: "complete", error: @room.errors.objects.first.full_message}
                return
            end
            @room.save
        end

        render_obj = {
            status: "complete", 
            room: @room
        }

        if request
            render_obj[:notification] = request
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
        params.permit(:id,:room_name,:users,:pending_approval,:admin,:search,:current_user,:request,:user_remove,:make_entry_key,:submitted_key)
    end

    def find_user
        user = User.find_by(username: rooms_params[:current_user])

        if !user
            render json: {status: "failed", error: "User could not be found"}
        end

        user
    end

    def find_room
        room = Room.find_by(room_name: rooms_params[:id])

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

    def request_to_admins(room,request)
        room_admins = room.admin["admin_users"].keys

        room_admins.each do |admin_names|
            admin_user = User.find_by(username: admin_names)
            admin_user.requests["roomAuth"][request] = TIME_INPUT
            admin_user.save
        end
    end

    def clear_admin_request(room,admitted_user)
        room_admins = room.admin["admin_users"].keys

        room_admins.each do |admin|
            admin_user = User.find_by(username: admin)

            admin_user.requests["roomAuth"].delete(admitted_user)
        end
    end
end
