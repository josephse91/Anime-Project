require 'json'

class Api::UsersController < ApplicationController
    NOW = Time.new
    TIME_INPUT = "#{NOW.month}-#{NOW.day}-#{NOW.year}"
    
    def index
        users_search = query_params[:search] ? "%" + query_params[:search] + "%": nil

        if users_search
            users = User.where(["username LIKE ?", users_search])
        else
            users = User.all;
        end

        render json: {status: "complete", users: users}
    end
    
    def create
        create_params = user_params.select {|key,value| key != "password" && value}
        @user = User.new(create_params)
        
        @user.password(user_params[:password]) if @user

        if @user.save
            render json: {status: "complete", user: @user}
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
        @user = find_user
        return if !@user

        user_peer_request = user_params[:requests]
        user_to_notify = nil

        # Conditional for an incoming request
        if user_peer_request
            user_requests = !@user.requests["peer"].nil? ? @user.requests["peer"] : {}
            param_obj = ActiveSupport::JSON.decode(user_peer_request)
            requests_action = param_obj["action"]
            request_focus = param_obj["requestFocus"]

            peer_check = peer_check(@user,request_focus,requests_action)
            return if peer_check

            peer_request_check = @user.requests["peer"][request_focus]

            if peer_request_check && requests_action == "add"
                render json: {status: "complete", requests: @user.requests["peer"], message: "User already sent request to this peer"}
                return
            end

            if requests_action == "remove"
                user_requests.delete(request_focus)
            elsif requests_action == "add"
                user_requests[request_focus] = TIME_INPUT
            end

            @user.save

            render_obj = {status: "complete", user: @user}
            requests_action == "add" ? render_obj[:notification] = @user.username : nil

            render json: render_obj
            return
        end

        # Should only allow the current user to be the one to change further attributes

        # if @user.username != current_user_username
        #     render json: {status: "failed", error: "Not authorized user", user: @user.username, current_user: current_user_username}
        #     return
        # end

        new_username = user_params[:new_username]
        new_password = user_params[:new_password]

        if new_username || new_password
            return if !check_password(@user)
            new_username ? @user.username = new_username : nil
            new_password ? @user.password(new_password) : nil
            @user.save

            render json: {user: @user}
            return
        end

        # If there is a potential peer in your request attribute, you can handle them with the following conditional
        user_peer_param = user_params[:peers]

        if user_peer_param
            user_peers = !@user.peers.nil? ? @user.peers : {}
            param_obj = ActiveSupport::JSON.decode(user_params[:peers])
            peers_action = param_obj["action"]
            peer_focus = param_obj["peerFocus"]
            peer_obj = User.find_by(username: peer_focus)

            peer_check = peer_check(@user,peer_focus,peers_action)
            return if peer_check
            
            if peers_action == "remove"
                user_peers.delete(peer_focus)
            elsif peers_action == "add"
                user_peers[peer_focus] = TIME_INPUT
                peer_obj.peers[@user.username] = TIME_INPUT
                peer_obj.save
                @user.requests["peer"].delete(peer_focus)
            end

            user_to_notify = peer_focus
            @user.update(peers: user_peers)

        end

        genre_preference = user_params[:genre_preference]
        go_to_motto = user_params[:go_to_motto]
        user_grade_protocol = user_params[:user_grade_protocol]

        if genre_preference || go_to_motto || user_grade_protocol
            @user.genre_preference = genre_preference || @user.genre_preference
            @user.go_to_motto = go_to_motto || @user.go_to_motto
            @user.user_grade_protocol = user_grade_protocol || @user.user_grade_protocol
            @user.save
        end

        render_obj = {status: "complete", user: @user}
        user_peer_param ? render_obj[:notification] = user_to_notify : nil

        render json: render_obj
    end

    def destroy
        if !current_user
            render json: {status: "failed", error: "not signed in"}
            return
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
        params.permit(:id,:username,:password,:genre_preference,:go_to_motto,:user_grade_protocol,:peers,:requests,:new_username,:new_password,:session_token_input)
    end

    def query_params
        params.permit(:search)
    end

    def check_password(user)
        password = user_params[:password] && @user.is_password?(user_params[:password])

        if !password
            render json: {status: "failed", error: "Incorrect Password"}
        end
        password
    end

    def find_user
        user = User.find_by(username: user_params[:id])
        
        if !user
            render json: {status: "failed", error: "no existing user"}
        end

        user
    end

    def peer_check(user,param_user,action)
        peer_exist = user.peers[param_user]

        if peer_exist && action == "add"
            render json: {status: "complete", peers: user.peers, message: "User already has this peer"}
            return
        end

        peer_exist && action == "add"
    end
end