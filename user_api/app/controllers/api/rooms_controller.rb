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
        @room = Room.find_by(room_name: rooms_params[:id])
        current_user = rooms_params[:current_user]

        request = rooms_params[:request]
        submitted_key = rooms_params[:submitted_key]
        room_keys = @room.entry_keys["keys"]

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
        end

        if !@room.users[current_user] 
            render json: {status: "failed", error: "Only users within room can update the room"}
            return
        end

        user_remove = rooms_params[:user_remove]
        generate_key = rooms_params[:make_entry_key]
        pending_user = @room.pending_approval[request]
        group_admin = @room.admin["group_admin"]
        room_admins = @room.admin["admin_users"][current_user]

        if rooms_params[:room_name]
            if group_admin || room_admins
                @room.room_name = rooms_params[:room_name] || @room.room_name
                @room.save
            else
                render json: {status: "failed", error: "Not authorized user"}
                return
            end
        end

        if (request || user_remove) && !submitted_key
            
            if group_admin || room_admins
                request ? @room.users[request] = TIME_INPUT : nil
                pending_user ? @room.pending_approval.delete(request) : nil
                user_remove && !group_admin ? @room.users.delete(user_remove) : nil
            else
                request ? @room.pending_approval[request] = TIME_INPUT : nil
            end
            @room.save
        end

        if generate_key
            key = Room.generate_entry_key
            @room.entry_keys["keys"][key] = Time.now.advance(days: 10).at_noon.getutc

            if !@room.valid?
                render json: {status: "complete", error: @room.errors.objects.first.full_message}
                return
            end
            @room.save
        end

        render json: {status: "complete", room: @room}
    end

    def destroy
        @room = Room.find_by(room_name: rooms_params[:id])
        user = User.find_by(username: rooms_params[:current_user])

        if @room.users.length > 0
            render json: {status: "failed", error: "There are still users within the Room"}
            return
        end

        render json: {status: "complete", room: @room}
        @room.destroy
    end

    def rooms_params
        params.permit(:id,:room_name,:users,:pending_approval,:admin,:search,:current_user,:request,:user_remove,:make_entry_key,:submitted_key)
    end

    def clean_expired_keys(room)
        deleted_keys = [];
        room.entry_keys["keys"].each do |key,val|
            expire_time = Time.parse(val)
            if expire_time < Time.now
                deleted_keys.push(key)
                room.entry_keys["keys"].delete(key)
            end
        end

        deleted_keys.length > 0 ? room.save : nil
        deleted_keys
    end
end
