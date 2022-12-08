require 'json'

class Api::UsersController < ApplicationController
    
    def create
        create_params = user_params.select {|key,value| key != "password" && value}
        @user = User.new(create_params)
        
        @user.password(user_params[:password]) if @user

        if @user.save
            render json: {status: "complete"}
        else
            error = @user.errors.messages.length > 0 ? @user.errors.messages : "Either the username or password is invalid"
            render json: {status: "failed", error: error}
        end
    end

    def show
        @user = User.find_by(username: user_params[:id])

        if !@user
            render json: {status: "failed", error: "no existing user"}
        else
            render :show
        end
    end

    def update
        #must check for current user before this. Similar to delete. For testing purposes, this will be left out
        @user = User.find_by(username: user_params[:id])
        if !@user
            render json: {status: "failed", error: "no existing user"}
            return
        end
        
        if user_params[:new_username]
            return if !check_password(@user)
            @user.update(username: user_params[:new_username])
        elsif user_params[:new_password]
            return if !check_password(@user)
            @user.password(user_params[:new_password])
            @user.save
        elsif user_params[:rooms]
            user_rooms = !@user.rooms.nil? ? ActiveSupport::JSON.decode(@user.rooms) : {}
            param_obj = ActiveSupport::JSON.decode(user_params[:rooms])
            rooms_action = param_obj["action"]
            focus_room = param_obj["focusRoom"]
            
            if (rooms_action == "remove")
                user_rooms.delete(focus_room)
            elsif (!user_rooms[focus_room] && rooms_action == "add")
                time = Time.new
                current_date = "#{time.month}/#{time.day}/#{time.year}"
                user_rooms[focus_room] = current_date
            end

            user_rooms = ActiveSupport::JSON.encode(user_rooms)
            @user.update(rooms: user_rooms)
        elsif user_params[:peers]
            user_peers = !@user.peers.nil? ? ActiveSupport::JSON.decode(@user.peers) : {}
            param_obj = ActiveSupport::JSON.decode(user_params[:peers])
            peers_action = param_obj["action"]
            focus_peer = param_obj["focusPeer"]
            
            if (peers_action == "remove")
                user_peers.delete(focus_peer)
            elsif (!user_peers[focus_peer] && peers_action == "add")
                time = Time.new
                current_date = "#{time.month}/#{time.day}/#{time.year}"
                user_peers[focus_peer] = current_date
            end

            user_peers = ActiveSupport::JSON.encode(user_peers)
            @user.update(peers: user_peers)

        elsif user_params[:requests]
            # convert request param into JSON
            param_obj = ActiveSupport::JSON.decode(user_params[:requests])
            requests_action = param_obj["action"]
            focus_type = param_obj["requestType"]
            focus_request = param_obj["focusRequest"]
            focus_val = param_obj["val"]

            # grab the user request JSON object. This object automatically converts into a hash
            user_requests =  @user.requests

            user_request_type = user_requests[focus_type]

            # The types of requests will have different values
            roomTypes = ["room","roomAuth"]
            peerTypes = ["peer"]
            
            # Logic to take care of whether the action is "remove" or "add"
            if requests_action == "remove"
                user_request_type.delete(focus_request)

            elsif !user_request_type[focus_request] && requests_action == "add" && roomTypes.include?(focus_type)

                user_request_type[focus_request] = focus_val

            elsif !user_request_type[focus_request] && requests_action == "add" && peerTypes.includes?(focus_type)

                time = Time.new
                current_date = "#{time.month}/#{time.day}/#{time.year}"
                user_request_type[focus_request] = current_date

            end
        
            # update the requests column
            @user.update(requests: user_requests)
            
        elsif !user_params[:password]
            @user.update(user_params)
        end

        render :update
    end

    def destroy
        if !current_user
            render json: {status: "failed", error: "not signed in"}
        end

        @user = User.find_by(session_token: user_params[:session_token_input])

        if !@user
            render json: {status: "failed", error: "not signed in - Invalid Session token"}
            return
        end

        if !user_params[:password] || !@user.is_password?(user_params[:password])
            render json: {status: "failed",error: "Invalid Password"}
            return
        end

        @user.destroy

        render json: {status: "complete"}
    end

    def user_params
        params.permit(:id,:username,:password,:genre_preference,:go_to_motto,:user_grade_protocol,:rooms,:peers,:requests,:new_username,:new_password,:session_token_input)
    end

    def check_password(user)
        password = user_params[:password] && @user.is_password?(user_params[:password])

        if !password
            render json: {status: "failed", error: "Incorrect Password"}
        end
        password
    end
end