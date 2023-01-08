class Api::ForumsController < ApplicationController
    def index
        forums = Forum.all
        
        render json: {status: "complete", forums: forums}
    end

    def room_forum_index
        room = find_room
        return if !room
        
        forum_search = forums_params[:forum_search]
        formatted_search = "%#{forum_search}%"
        anime_search = forums_params[:anime_search]

        if !room
            render json: {status: "failed", error: "The room doesn't exist"}
            return
        end

        query = ["forums.room_id = ?",room]

        if forum_search
            query[0] += " AND (LOWER(topic) LIKE ? OR LOWER(content) LIKE ?"
            query.push(formatted_search,formatted_search)
        end

        if anime_search
            query[0] += " OR LOWER(anime) = ?"
            query.push(anime_search)
        end

        query[0] +=")"
        forums = Forum.where(query)

        render json: {status: "complete", forums: forums}
    end

    def show
        forum = find_forum
        return if !forum

        if !forum
            render json: {status: "failed", error: "Forum could not be found"}
            return
        end

        render json: {status: "complete", forum: forum}

    end

    def create
        alter_forum = forum_attributes
        return if !alter_forum

        components = alter_forum[:components]
        forum = alter_forum[:forum]
        room = alter_forum[:room]
        notifications = []

        forum = Forum.new(components)

        if forum.invalid?
            render json: {status: "failed", error: forum.errors.objects.first.full_message}
            return
        end
        forum.save
        
        render_obj = {status: "complete", components: forum}
        add_notification(notifications,forum,room)

        render_obj[:notifications] = notifications
        render json: render_obj
    end

    def update
        alter_forum = forum_attributes
        return if !alter_forum

        components = alter_forum[:components]
        forum = alter_forum[:forum]

        valid_test = Forum.new(components)

        if valid_test.invalid?
            render json: {status: "failed", error: valid_test.errors.objects.first.full_message}
            return
        else
            forum.update(components)
        end

        render json: {status: "complete", forum: forum}
    end

    def destroy
        user_room = access_granted
        return if !user_room
        current_user,room = user_room

        forum = confirm_forum_owner(current_user)
        return if !forum

        render json: {status: "complete", forum: forum}

        forum.destroy
    end

    def valid_user
        current_user = forums_params[:current_user]
        user = User.find_by(username: current_user)

        if !user
            render json: {status: "failed", vari: [user,room], error: "Invalid user"}
        end

        user
    end

    def find_room
        room_input = forums_params[:room_id]
        room = Room.find_by(room_name: room_input)

        if !room
            render json: {status: "failed", error: "Invalid Room"}
        end

        room
    end

    def access_granted
        user = valid_user
        return nil if !user

        room = find_room
        return if !room

        user_in_room = user.rooms[room.room_name]
        room_contains_user = room.users[user.username]

        if !user_in_room || !room_contains_user
            render json: {status: "failed", user: user, room: room, error: "User must be within room to edit forum"}
            return nil
        end

        [user,room]
    end

    def find_forum
        forum = Forum.find_by(id: forums_params[:id])

        if !forum && forums_params[:id]
            render json: {status: "failed", error: "No forum can be found"}
            return
        end

        forum
    end

    def confirm_forum_owner(current_user)
        forum = find_forum
        return if !forum

        if forum && current_user.username != forum&.creator
            render json: {
                status: "failed", 
                error: "Only the creator of the post can edit the post"
            }
            return
        end

        forum
    end

    def forum_attributes
        user_room = access_granted
        return nil if !user_room

        current_user,room = user_room
        notifications = []

        forum = find_forum

        if forum
            votes_hash = adjust_votes(notifications,current_user,forum)
            return nil if votes_hash[:action]
            votes = votes_hash[:votes]
        end

        forum = confirm_forum_owner(current_user)
        return if !forum && forums_params[:id]

        topic = forums_params[:topic] || forum&.topic
        content = forums_params[:content]
        anime = forums_params[:anime]

        components = {
            topic: topic,
            creator: current_user.username,
            room_id: room.room_name
        }

        content ? components[:content] = content : nil
        anime ? components[:anime] = anime : nil

        {components: components, forum: forum, room: room}
    end

    def add_notification(notifications,forum_post,room)
        users = room.users.each_key do |username|
            data = {
                action: "Created a forum post",
                target_item: "Room",
                action_user: room.room_name,
                recipient: username,
                id: forum_post.id,
                topic: forum_post.topic,
                forum_owner: forum_post.creator
            }
            notifications.push(data)
            notifications
        end

        notifications
    end

    def adjust_votes(notifications,user,forum)
        action_hash = forums_params[:votes]
        return {action: nil, votes: forum.votes} if !action_hash

        action = ActiveSupport::JSON.decode(action_hash)
        # review_check = Review.find_by(id: action["review_id"])

        # if review != review_check
        #     render json: {status: "failed", error: "Review not matching parameters"}
        #     return
        # end

        up_votes = forum.votes["up"]
        down_votes = forum.votes["down"]

        net = action["net"]
        target = action["target"]

        if net == 1 && target == 0
            forum.votes = {"up": up_votes - 1, "down": down_votes}
            event = "neutral"
        elsif net == 1 && target == -1
            forum.votes = {"up": up_votes - 1, "down": down_votes + 1}
            event = "unlike"
        elsif net == 0 && target == 1
            forum.votes = {"up": up_votes + 1, "down": down_votes}
            event = "like"
        elsif net == 0 && target == -1
            forum.votes = {"up": up_votes, "down": down_votes - 1}
            event = "unlike"
        elsif net == -1 && target == 0
            forum.votes = {"up": up_votes + 1, "down": down_votes}
            event = "neutral"
        elsif net == -1 && target == 1
            forum.votes = {"up": up_votes + 1, "down": down_votes - 1}
            event = "like"
        end

        forum.save

        data = {
            id: forum.id,
            recipient: forum.creator,
            net: net,
            action: event,
            action_user: user.username,
            target_item: "Forum"
        }

        event == "like" ? notifications.push(data) : nil
        render_obj = {status: "complete", action: event, like_action: data, forum: forum}
        notifications.length > 0 ? render_obj[:notifications] = notifications : nil

        render json: render_obj

        {action: event, forum: forum}
    end

    def forums_params
        params.permit(:id,:forum_search, :room_id,:anime_search, :current_user,:topic,:content, :anime, :votes)
    end
end