class Api::ForumsController < ApplicationController
    def index
        forums = Forum.all
        
        render json: {status: "complete", forums: forums}
    end

    def room_forum_index
        room = forums_params[:room_id]
        forum_search = forums_params[:forum_search]
        formatted_search = "%#{forum_search}%"
        anime_search = forums_params[:anime_search]

        if !room
            render json: {status: "failed", error: "The room doesn't exist"}
            return
        end

        query = ["forums.room = ?",room]

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
        forum = Forum.find_by(id: forums_params[:id])

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

        forum = Forum.new(components)

        if forum.invalid?
            render json: {status: "failed", error: forum.errors.objects.first.full_message}
            return
        else
            forum.save
        end

        render json: {status: "complete", components: forum}
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

    def access_granted
        user = valid_user
        return nil if !user
        room = forums_params[:room_id]

        user_in_room = user ? user.rooms[room] : nil

        if !user_in_room
            render json: {status: "failed", error: "User must be within room to edit forum"}
            return nil
        end

        [user,room]
    end

    def confirm_forum_owner(current_user)
        forum = Forum.find_by(id: forums_params[:id])

        if forum && current_user.username != forum.creator
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
        forum = confirm_forum_owner(current_user)
        return if !forum && forums_params[:id]

        topic = forums_params[:topic] || forum&.topic
        content = forums_params[:content]
        anime = forums_params[:anime]
        votes = forums_params[:votes]

        components = {
            topic: topic,
            creator: current_user.username,
            room: room
        }

        content ? components[:content] = content : nil
        anime ? components[:anime] = anime : nil
        votes ? components[:votes] = votes : nil

        {components: components, forum: forum}
    end

    def forums_params
        params.permit(:id,:forum_search, :room_id,:anime_search, :current_user,:topic,:content, :anime, :votes)
    end
end