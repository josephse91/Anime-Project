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
        components = comment_attrs[:components]
        return if !components
        
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
        user_id = comments_param[:user_id]
        comment = confirm_comment_owner(user_id)
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
        params.permit(:id,:comment,:review_id,:user_id,:top_comment,:comment_type,:parent,:change_likes)
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
        comment_type = comments_param[:comment_type]
        parent = comments_param[:parent]
        user_id = comments_param[:user_id]
        review_id = comments_param[:review_id]
        review = Review.find_by(id: review_id)
        notification_target = []
        
        if comment_type == "reply"
            parent = ReviewComment.find_by(id: comments_param[:parent])
            top_comment = parent.id
            add_notification(notification_target,review,user_id,parent)
        elsif comment_type == "comment"
            parent = Review.find_by(id: comments_param[:parent])
            top_comment = ReviewComment.last.id + 1
            add_notification(notification_target,review,user_id)
        end

        if !parent
            render json: {status: "failed", parent: parent, error: "Review or Comment does not exist"}
            return nil
        end

        comments_param[:id] ? review_comment = confirm_comment_owner(user_id) : nil
        return if !review_comment && comments_param[:id]

        comment = comments_param[:comment]
        likes = comments_param[:change_likes]
        
        parent = parent.id

        components = {
            review_id: review_id,
            comment: comment,
            user_id: user_id,
            comment_type: comment_type,
            parent: parent,
            top_comment: top_comment
        }

        likes ? components[:likes] = likes : nil

        {components: components, notification: notification_target}
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
        notifications.push(reviewer)

        if comment
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
