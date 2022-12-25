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
        
        comment = ForumComment.new(attributes)

        if comment.valid?
            comment.save
            comment.top_comment = comment.top_comment || comment.id
            comment.save
            set_children(parent,comment)
        else
            render json: {status: "failed", error: comment.errors.objects.first.full_message}
        end

        render json: {status: "complete", comment: comment}

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
            
            if children.length > 0
                children = children.map do |child| 
                    ForumComment.find_by(id: child["id"])
                end
            end

            bfs.push(*children)

            current_comment.destroy
        end

        render json: {status: "complete", comment: comment}
    end

    def find_user
        user = User.find_by(username: comment_params[:comment_owner])

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

        if !comment
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

    def add_vote(vote_param)
        comment = ForumComment.find_by(id: comment_params[:id])

        if !comment
            render json: {status: "failed", error: "Forum comment could not be found"}
            return
        end

        comment.votes = vote_param
        render json: {status: "complete", votes: comment.votes}
    end

    def set_children(parent,child)
        parent ? parent.children.unshift(child) : nil
        parent ? parent.save : nil

        current_parent = parent
        current_child = child

        while current_parent
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

        child
    end

    def create_components_hash
        votes = comment_params[:votes]
        current_user = find_user
        return if !current_user && !votes

        forum_comment_param = comment_params[:id]
        forum_comment = ForumComment.find_by(id: forum_comment_param)

        if votes
            if !forum_comment
                render json: {status: "failed", error: "couldn't find comment"}
            else
                forum_comment.votes = votes
                forum_comment.save
                render json: {status: "complete", votes: forum_comment.votes}
            end
            return
        end

        if forum_comment
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

        {parent: parent_obj, attributes: attributes}
    end

    def comment_params
        params.permit(:id,:forum_id,:comment,:comment_owner,:level,:parent,:children,:votes)
    end
end
