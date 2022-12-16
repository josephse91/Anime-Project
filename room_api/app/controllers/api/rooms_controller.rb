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
        
    end

    def update
        @room = Room.find_by(room_name: rooms_params[:id])
        current_user = rooms_params[:current_user]

        if !@room.users[current_user] 
            render json: {status: "failed", error: "Only users within room can update the room"}
            return
        end

        request = rooms_params[:request]
        group_admin = @room.admin["group_admin"]
        room_admins = @room.admin["admin_users"][current_user]

        if rooms_params[:room_name]
            if group_admin == "true" || room_admins
                @room.room_name = rooms_params[:room_name] || @room.room_name
                @room.save
            else
                render json: {status: "failed", error: "Not authorized user"}
                return
            end
        end

        if rooms_params[:request]
            if group_admin == "true" || room_admins
                request ? @room.users[request] = @room.users[request] || TIME_INPUT : nil
            else
                request ? @room.pending_approval[request] = TIME_INPUT : nil
            end
            @room.users[request] ? nil : @room.save
        end


        render json: {status: "complete", room: @room}
    end

    def destroy
        @room = Room.find_by(room_name: rooms_params[:id])

        
    end

    def rooms_params
        params.permit(:id,:room_name,:users,:pending_approval,:admin,:search,:current_user,:request)
    end
end
