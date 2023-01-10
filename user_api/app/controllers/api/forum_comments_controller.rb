class Api::ForumCommentsController < ApplicationController
    NOW = Time.new.to_fs(:db)

    def index
        forum = find_forum
        return if !forum

        where_condition = ["forum_id= ? AND parent IS NULL",forum.id]
        comments = ForumComment.where(where_condition).order(created_at: :asc)

        render json: {status: "complete", comments: comments}
    end
    
    def create
        comment_components = create_components_hash
        return if !comment_components

        attributes = comment_components[:attributes]
        parent = comment_components[:parent]
        forum = comment_components[:forum]
        
        comment = ForumComment.new(attributes)

        if comment.valid?
            comment.save
            comment.top_comment = comment.top_comment || comment.id
            comment.save
            touched_comments = set_children(parent,comment,forum, "Comment")
        else
            render json: {status: "failed", error: comment.errors.objects.first.full_message}
        end

        notifications = touched_comments[:notifications]
        render_obj = {status: "complete", comment: comment}

        render_obj[:notifications] = notifications
        render json: render_obj

    end

    def update
        comment_components = create_components_hash
        return if !comment_components
        attributes = comment_components[:attributes]

        comment = ForumComment.new(attributes)

        if comment.valid?
            comment.save
        else
            render json: {status: "failed", error: comment.errors.objects.first.full_message}
        end

        render json: {status: "complete", comment: comment}
    end

    def destroy
        current_user = find_user
        return if !current_user

        comment_unauthorized = find_comment
        return if !comment_unauthorized

        comment = comment_authorization(current_user,comment_unauthorized)
        return if !comment

        bfs = [comment]

        while bfs.length > 0
            current_comment = bfs.shift
            children = current_comment&.children
            
            if children&.length > 0
                children = children.map do |child| 
                    ForumComment.find_by(id: child["id"])
                end

                bfs.push(*children)
            end

            current_comment.destroy
        end

        render json: {status: "complete", comment: comment}
    end

    def find_user
        user_param = comment_params[:current_user] || comment_params[:comment_owner]
        user = User.find_by(username: user_param)

        if !user
            render json: {status: "failed", error: "User does not exist"}
            return
        end

        user
    end

    def find_forum
        forum = Forum.find_by(id: comment_params[:forum_id])

        if !forum
            render json: {status: "failed", error: "Forum post does not exist"}
            return
        end

        forum
    end

    def find_comment
        comment = ForumComment.find_by(id: comment_params[:id])

        if !comment && comment_params[:id]
            render json: {status: "failed", error: "Could not find comment"}
            return
        end

        comment
    end

    def room_authorization(current_user,forum)
        room = Room.find_by(room_name: forum.room_id)
        if !room.users[current_user.username]
            render json: {status: "failed", error: "Only users within room can leave comments"}
            return
        end
        forum
    end

    def comment_authorization(current_user,comment)
        if comment.comment_owner != current_user.username
            render json: {status: "failed", error: "Only owner of the comment can change the comment"}
            return
        end

        comment
    end

    def set_children(parent,child,forum,action)
        notifications = []
        parent ? parent.children.unshift(child) : nil
        parent ? parent.save : nil

        current_parent = parent || forum
        current_child = child

        if action == "Comment"
            add_notification(notifications, current_parent, current_child,forum,action)
        end

        while current_parent && current_parent.is_a?(ForumComment)
            already_exists = nil

            current_parent.children.each_with_index do |ex_child,idx|
                if ex_child["id"] == current_child.id
                    already_exists = idx
                end
            end

            if already_exists
                current_parent.children[already_exists] = current_child
            else
                current_parent.children.unshift(current_child)
            end

            current_parent.save
            current_child = current_parent
            current_parent = ForumComment.find_by(id: current_child.parent)
        end

        {comment: child, notifications: notifications}
    end

    def create_components_hash
        votes = comment_params[:votes]
        current_user = find_user
        return if !current_user

        forum_comment = find_comment
        notifications = []

        if forum_comment
            votes_hash = adjust_votes(notifications,current_user,forum_comment)
            return nil if votes_hash[:action]
            comment_confirmed = comment_authorization(current_user,forum_comment)
        end

        return if !comment_confirmed && forum_comment

        forum = find_forum
        return if !forum

        room_check = room_authorization(current_user,forum)
        return if !room_check

        comment = comment_params[:comment] || comment_confirmed&.comment
        
        parent = comment_params[:parent] || comment_confirmed&.parent
        parent_obj = ForumComment.find_by(id: parent)

        level = parent_obj ? parent_obj.level + 1 : 1
        parent_obj ? top_comment = parent_obj.top_comment : nil

        attributes = {
            comment: comment,
            forum_id: forum.id,
            comment_owner: current_user.username,
            level: level,
            parent: parent
        }

        top_comment ? attributes[:top_comment] = top_comment : nil

        {parent: parent_obj, attributes: attributes, forum: forum}
    end

    def add_notification(notifications, parent, comment,forum,action)
        recipient = parent.is_a?(Forum) ? parent.creator : parent.comment_owner
        target_item = parent.is_a?(Forum) ? "Forum" : "Forum Comment"

        data = {
            action: action,
            action_user: comment.comment_owner,
            recipient: recipient,
            target_item: target_item,
            topic: forum.topic,
            room: forum.room_id,
            id: parent.id
        }

        notifications.push(data)
        notifications
    end

    def adjust_votes(notifications,user,comment)
        action_hash = comment_params[:votes]
        return {action: nil, votes: comment.votes} if !action_hash

        action = ActiveSupport::JSON.decode(action_hash)
        # review_check = Review.find_by(id: action["review_id"])

        # if review != review_check
        #     render json: {status: "failed", error: "Review not matching parameters"}
        #     return
        # end

        up_votes = comment.votes["up"]
        down_votes = comment.votes["down"]

        net = action["net"]
        target = action["target"]

        if net == 1 && target == 0
            comment.votes = {"up": up_votes - 1, "down": down_votes}
            event = "neutral"
        elsif net == 1 && target == -1
            comment.votes = {"up": up_votes - 1, "down": down_votes + 1}
            event = "unlike"
        elsif net == 0 && target == 1
            comment.votes = {"up": up_votes + 1, "down": down_votes}
            event = "like"
        elsif net == 0 && target == -1
            comment.votes = {"up": up_votes, "down": down_votes - 1}
            event = "unlike"
        elsif net == -1 && target == 0
            comment.votes = {"up": up_votes + 1, "down": down_votes}
            event = "neutral"
        elsif net == -1 && target == 1
            comment.votes = {"up": up_votes + 1, "down": down_votes - 1}
            event = "like"
        end

        comment.save
        parent = ForumComment.find_by(parent: comment.parent)
        forum = Forum.find_by(id: comment.forum_id)
        notifications = set_children(parent,comment,forum,"like")[:notifications]

        data = {
            action: "like",
            target_item: "Forum Comment",
            net: net,
            action_user: user.username,
            recipient: comment.comment_owner,
            room: forum.room_id,
            id: comment.id
        }

        event == "like" ? notifications.push(data) : nil
        render_obj = {status: "complete", action: event, like_action: data, comment: comment}
        notifications.length > 0 ? render_obj[:notifications] = notifications : nil

        render json: render_obj

        {action: event, comment: comment}
    end

    def comment_params
        params.permit(:id,:forum_id,:comment,:comment_owner,:parent,:children,:votes, :current_user)
    end
end
