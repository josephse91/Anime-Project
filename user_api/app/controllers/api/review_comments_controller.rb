class Api::ReviewCommentsController < ApplicationController
    def index
        review = find_review
        return if !review

        sql = <<-SQL
        SELECT *, FIRST_VALUE(top_comment) OVER(
            PARTITION BY top_comment
            ORDER BY comment_type ASC, created_at ASC
        ) AS comment_segment
        FROM review_comments
        WHERE review_id = #{review.id}
        SQL

        @comments = ReviewComment.find_by_sql(sql)
        render json: {status: "completed", comments: @comments, review: review}
        #render :index
    end

    def create
        return if !comment_attrs
        components = comment_attrs[:components]

        comment = ReviewComment.new(components)

        if (comment.valid?)
            comment.save
            notifications = comment_attrs[:notification]
            render_obj = {status: "complete", comment: comment}

            render_obj[:notifications] = notifications
            render json: render_obj
        else
            render json: {status: "failed", errors: comment.errors.objects.first.full_message}
        end
    end

    def update
        components = comment_attrs
        return if !comment_attrs
        
        existing_comment = components[:existing_comment]
        new_comment = components[:comment]

        existing_comment.comment = new_comment

        if (existing_comment.valid?)
            existing_comment.save
            render json: {status: "complete", comment: existing_comment}
        else
            render json: {status: "failed", errors: existing_comment.errors.objects.first.full_message}
        end
    end

    def destroy
        user = find_user
        return if !user

        comment = find_comment
        return if !comment

        return if !confirm_comment_owner(user,comment)

        delete_stack = []

        destroyed_comments = {};

        replies = ReviewComment.where(parent: comment.id) # address this parent
        delete_stack.push(comment,*replies)

        delete_stack.each do |item|
            item_id = item.id
            destroyed_comments[item_id] = {
                id: item.id,
                review_id: item.review_id,
                top_comment: item.top_comment,
                comment_type: item.comment_type,
                user_id: item.user_id,
                parent: item.parent,
                comment: item.comment,
                likes: item.likes
            }
            item.destroy
            check = ReviewComment.find_by(id: item_id)

            if check
                render json: {status: "failed", parent: parent, error: "Did not delete all comments. id: #{item.id} count not be deleted"}
                return nil
            end
        end

        render json: {status: "complete", deleted_comments: destroyed_comments}

    end

    def comments_param
        params.permit(:id,:comment,:review_id,:user_id,:top_comment,:comment_type,:parent,:likes)
    end

    def find_user
        user = current_user
        if !user
            render json: {status: "failed", user: user,error: "Invalid user"}
            return
        end

        user
    end

    def find_comment
        comment_id = comments_param[:id]
        comment = ReviewComment.find_by(id: comment_id)

        if !comment && comment_id
            render json: {status: "failed", error: "Comment does not exist"}
            return
        end

        comment
    end

    def find_review
        review = Review.find_by(id: comments_param[:review_id])

        if !review
            render json: {
                status: "failed", 
                error: "The review could not be found"
            }
            return
        end

        review
    end

    def confirm_comment_owner(current_user,existing_comment)
        #review_comment = find_comment
        #return if !review_comment

        p "confirm-owner #{current_user} and #{existing_comment.user_id}"

        owner = current_user.username == existing_comment.user_id
        if !owner
            render json: {
                status: "failed", 
                error: "Only the creator of the post can edit the post"
            }
            return
        end

        owner
    end

    def comment_attrs(comment = nil) 

        client_user = find_user
        return if !client_user
        p "current_user: #{client_user}"
        user_id = client_user.username

        existing_comment = find_comment
        like_check = comments_param[:likes]

        if existing_comment && like_check
            adjust_likes(notifications,review,existing_comment)
            return
        end
        p "current_user: #{client_user}/ existing_comment: #{existing_comment}"
        components = {}

        comment = comments_param[:comment]
        components[:comment] = comment

        owner_confirm = nil 
        
        if existing_comment
            owner_confirm = confirm_comment_owner(client_user,existing_comment)
            return if !owner_confirm

            if owner_confirm
                components[:id] = existing_comment.id
                components[:existing_comment] = existing_comment
            end
            return components
        end

        review_id = comments_param[:review_id]
        review = find_review 
        return if !review

        comment_type = comments_param[:comment_type]
        parent = comments_param[:parent]

        notifications = []

        components[:review_id] = review_id
        components[:user_id] = client_user.username
        components[:comment_type] = comment_type
        components[:parent] = parent
        
        parent_obj = ReviewComment.find_by(id: parent)
        if comment_type == "reply" 
            top_comment = parent_obj.id
            !owner_confirm ? add_notification(notifications,review,client_user,components) : nil
        elsif comment_type == "comment"
            top_comment = ReviewComment.last.id + 1
            !owner_confirm ? add_notification(notifications,review,user_id) : nil
        end

        if !parent
            render json: {status: "failed", parent: parent, error: "Review or Comment requires parent"}
            return nil
        end

        components[:top_comment] = top_comment

        {components: components, notification: notifications}
    end

    def adjust_likes(notifications,review,comment)
        action_hash = comments_param[:likes]
        return {action: nil, likes: comment.likes} if !action_hash

        action = ActiveSupport::JSON.decode(action_hash)
        # review_check = Review.find_by(id: action["review_id"])

        # if review != review_check
        #     render json: {status: "failed", error: "Review not matching parameters"}
        #     return
        # end

        like_count = comment.likes
        initial_like = action["initialLike"]
        target_like = action["targetLike"]

        # The like count will always change by the absolute difference between the target and the net
        if initial_like < target_like
            comment.likes = like_count + (target_like - initial_like)
            event = "like"
        elsif initial_like > target_like
            comment.likes = like_count - (initial_like - target)
            event = "unlike"
        end

        comment.save

        data = {
            id: comment.id,
            recipient: comment.user_id,
            initialLike: initial_like,
            action: event,
            action_user: review.user,
            target_item: "Review Comment",
            show: review.show
        }
        event == "like" ? notifications.push(data) : nil
        render_obj = {status: "complete", action: event, like_action: data, comment: comment}
        notifications.length > 0 ? render_obj[:notifications] = notifications : nil

        render json: render_obj

        {action: event, comment: comment}
    end

    def add_notification(notifications,review,current_user,comment = nil)
        reviewer = {
            id: review.id,
            recipient: review.user,
            show: review.show,
            action: "Comment",
            action_user: current_user,
            target_item: "Review"
        }
        if current_user != review.user
            notifications.push(reviewer)
        end

        if comment && current_user.username != comment[:user_id]
            commenter = {
                id: comment[:id],
                recipient: comment[:user_id],
                review: comment[:review_id],
                show: review.show,
                target_item: "Review Comment",
                action: "Comment",
                action_user: current_user
            }
            notifications.push(commenter)
        end

        notifications
    end
end
