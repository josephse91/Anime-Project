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

    def user_rooms
        user = find_user
        return if !user

        room_hash = user.rooms
        rooms = room_hash.map {|room,date| Room.find_by(room_name: room)}

        render json: {status: "complete", user: user, rooms: rooms}
    end
    
    def create
        create_params = user_params.select {|key,value| key != "password" && value}
        @user = User.new(create_params)
        
        @user.password(user_params[:password]) if @user

        if @user.save
            login_user!(@user)
            render json: {status: "complete", user: @user}
        else
            error = @user.errors.messages.length > 0 ? @user.errors.messages : "Either the username or password is invalid"
            render json: {status: "failed", error: error}
        end
    end

    def show
        @user = find_user
        return if !@user

        render json: {status: "complete", user: @user}

    end

    def update
        #must check for current user before this. Similar to delete. For testing purposes, this will be left out
        @user = find_user
        return if !@user

        request_param = user_params[:requests]
        client_user = current_user
        notifications = []

        #In order to edit the current_user or target_user model, the current_user must be logged in
        if !logged_in?()
            render json: {status: "failed", error: "Not authorized user", user: @user.username, current_user: @user, params: user_params}
            return
        end

        # Conditional for an incoming request
        if request_param
            user_requests_hash = !@user.requests["peer"].nil? ? @user.requests["peer"] : {}
            request_param_hash = ActiveSupport::JSON.decode(request_param)
            requests_action = request_param_hash["action"]
            request_focus = request_param_hash["requestFocus"]
            requester_object = User.find_by(username: request_focus)

            #peer_check is a function below
            peer_check = peer_check(@user,request_focus,requests_action)
            return if peer_check

            peer_request_check = requester_object.requests["peer"][@user.username]

            if peer_request_check && requests_action == "add"
                render json: {status: "failed", 
                    error: "request already sent", requestee: @user, 
                    user_requested: {username:@user.username, peer_requests: @user.requests["peer"]}
                }
                return
            end

            if requests_action == "remove"
                user_requests_hash.delete(client_user.username)
                @user.save
            elsif requests_action == "add"
                user_requests_hash[client_user.username] = TIME_INPUT
            end

            @user.save

            render_obj = {status: "complete", user: @user}

            if requests_action == "add"
                add_notification(notifications,client_user,requester_object,"Sent a Request")
                #requestee_object.save
                render_obj[:notifications] = notifications
            end

            render json: render_obj
            return
        end

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
            
            if peers_action == "remove" # delete peers on both sides
                user_peers.delete(peer_focus)
                peer_obj.peers.delete(@user.username)
            elsif peers_action == "add"
                user_peers[peer_focus] = TIME_INPUT
                peer_obj.peers[@user.username] = TIME_INPUT
                add_notification(notifications,@user,peer_obj,"Accepted Request")
                peer_obj.save
                @user.requests["peer"].delete(peer_focus)
            end

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
        user_peer_param ? render_obj[:notifications] = notifications : nil

        render json: render_obj
    end

    def destroy
        user = current_user

        if !user
            render json: {status: "failed", error: "not signed in"}
            return
        end

        if !user_params[:password] || !user.is_password?(user_params[:password])
            render json: {status: "failed",error: "Invalid Password"}
            return
        end

        #delete features that are tied to the respective user
        reviews = Review.where(user: user.username)
        reviews.destroy_all

        user.peers.each do |peer_username,date|
            peer = User.find_by(username: peer_username)
            peer_associates = peer.peers
            peer_associates.delete(user.username)
            peer.update(peers: peer_associates)
        end

        #needs revisions for rooms. (After room controller is looked at)
        user.rooms.each do |room_name,date|
            room = Room.find_by(room_name: room_name)

            private_room_check = room.private_room
            group_admin_check = room.admin["group_admin"]

            if private_room_check && !group_admin_check
                room.admin["group_admin"] = false
            end
 
            room.users.delete(user.username)
            if room.users.keys.length = 0
                room.retired = true
            else
                
            room.save
        end

        recommendations = Recommendation.where(user_id: user.username)
        recommendations.destroy_all

        watch_laters = WatchLater.where(user_id: user.username)
        watch_laters.destroy_all

        # logic for orphaned data. forum and forum comments
        Forum.where(creator: user.username).update_all(creator: "Deleted User")
        ForumComment.where(comment_owner: user.username).update_all(comment_owner: "Deleted User")

        # DELETE USER
        temp_user = user
        user.destroy

        render json: {status: "complete", deleted_user: temp_user}
    end

    def user_params
        params.permit(:id, :user_id, :username,:password,:genre_preference,:go_to_motto,:user_grade_protocol,:peers,:requests,:new_username,:new_password,:session_token_input)
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
        search_user = user_params[:id] || user_params[:user_id]
        user = User.find_by(username: search_user)
        
        if !user
            render json: {status: "failed", error: "no existing user"}
        end

        user
    end

    def peer_check(user,param_user,action)
        
        peer_exist = user.requests["peer"][param_user] if user_params[:requests]
        peer_exist = user.peers[param_user] if user_params[:peers]

        if peer_exist && action == "add"
            render json: {status: "complete", user: user.username, peers: user.peers, message: "User already has this peer"}
        end
        p "user: #{user.username}/ peer_exist: #{peer_exist}/ action: #{action}"
        peer_exist && action == "add"
    end

    def add_notification(notifications,action_user,recipient_user,request_type)
        data = {
            id: action_user.id,
            recipient: recipient_user.username,
            action: request_type,
            action_user: action_user.username,
            target_item: "User"
        }
        notifications.push(data)
        notifications
    end
end