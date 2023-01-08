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
        render :index
    end

    def create
        components = comment_attrs[:components]
        return if !components

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
        component_hash = comment_attrs
        return if !component_hash

        components = component_hash[:components]
        
        comment = ReviewComment.find_by(id: comments_param[:id])
        valid_check = ReviewComment.new(components)

        if (valid_check.valid?)
            comment.update(components)
            render json: {status: "complete", comment: comment}
        else
            render json: {status: "failed", errors: comment.errors.objects.first.full_message}
        end
    end

    def destroy
        user = find_user
        return if !user

        comment = confirm_comment_owner(user)
        return if !comment

        delete_stack = []

        if !comment
            render json: {status: "failed", parent: parent, error: "Comment does not exist"}
            return nil
        end

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

        render json: {status: "complete", comments: destroyed_comments}

    end

    def comments_param
        params.permit(:id,:comment,:review_id,:user_id,:top_comment,:comment_type,:parent,:likes)
    end

    def find_user
        user = User.find_by(username: comments_param[:user_id])

        if !user
            render json: {status: "failed", user: user,error: "Invalid user"}
            return
        end

        user
    end

    def find_comment
        comment = ReviewComment.find_by(id: comments_param[:id])

        if !comment 
            render json: {status: "failed", error: "Comment does not exist"}
            return
        end

        comment
    end

    def find_review
        review = Review.find_by(id: comments_param[:review_id])
    end

    def confirm_comment_owner(current_user)
        review_comment = find_comment
        return if !review_comment

        if current_user != review_comment.user_id
            render json: {
                status: "failed", 
                error: "Only the creator of the post can edit the post"
            }
            return
        end

        review_comment
    end

    def comment_attrs(comment = nil) 
        user = find_user
        return if !user
        user_id = user.username

        comment_type = comments_param[:comment_type]
        parent = comments_param[:parent]
        review_id = comments_param[:review_id]
        review = Review.find_by(id: review_id)
        notifications = []

        if comments_param[:id]
            target_comment = find_comment

            likes_hash = target_comment ? adjust_likes(notifications,user,target_comment) : {}
            likes = likes_hash[:likes]
            return nil if likes_hash[:action]
        end
        
        if comment_type == "reply"
            parent = ReviewComment.find_by(id: comments_param[:parent])
            top_comment = parent.id
            add_notification(notifications,review,user,parent)
        elsif comment_type == "comment"
            parent = Review.find_by(id: comments_param[:parent])
            top_comment = ReviewComment.last.id + 1
            add_notification(notifications,review,user_id)
        end

        if !parent && !target_comment
            render json: {status: "failed", parent: parent, error: "Review or Comment does not exist"}
            return nil
        end

        comments_param[:id] ? review_comment = confirm_comment_owner(user_id) : nil
        return if !review_comment && target_comment

        comment = comments_param[:comment]
        
        parent = target_comment&.parent || parent&.id

        components = {
            comment: comment,
        }

        review_id ? components[:review_id] = review_id : nil
        user_id ? components[:user_id] = user_id : nil
        comment_type ? components[:comment_type] = comment_type : nil
        parent ? components[:parent] = parent : nil
        top_comment ? components[:top_comment] = top_comment : nil

        {components: components, notification: notifications}
    end

    def adjust_likes(notifications,user,comment)
        action_hash = comments_param[:likes]
        return {action: nil, likes: comment.likes} if !action_hash

        action = ActiveSupport::JSON.decode(action_hash)
        # review_check = Review.find_by(id: action["review_id"])

        # if review != review_check
        #     render json: {status: "failed", error: "Review not matching parameters"}
        #     return
        # end

        like_count = comment.likes
        net = action["net"]
        target = action["target"]

        if net < target
            comment.likes = like_count + 1
            event = "like"
        elsif net > target
            comment.likes = like_count - 1
            event = "unlike"
        end

        comment.save

        data = {
            id: comment.id,
            recipient: comment.user_id,
            net: net,
            action: event,
            action_user: user.username,
            target_item: "Review Comment"
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
            action_user: current_user.username,
            target_item: "Review"
        }
        if current_user.username != review.user
            notifications.push(reviewer)
        end

        if comment && current_user.username != comment.user_id
            commenter = {
                id: comment.id,
                recipient: comment.user_id,
                review: comment.review_id,
                show: review.show,
                target_item: "Comment",
                action: "Comment",
                action_user: current_user
            }
            notifications.push(commenter)
        end

        notifications
    end
end
