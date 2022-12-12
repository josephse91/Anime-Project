class Api::ReviewCommentsController < ApplicationController
    def index
        review = find_review
        return if !review

        # comments = ReviewComment.all.where(review_id: review.id).order(created_at: :desc)

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
        components = comment_attrs
        return if !components

        comment = ReviewComment.update(components)

        if (comment.save)
            render json: {status: "complete", review: comment}
        else
            render json: {status: "failed", errors: comment.errors.objects.first.full_message}
        end
    end

    def update
        components = comment_attrs
        return if !components
        
        comment = ReviewComment.find_by(id: comments_param[:id])

        if (comment&.update(components))
            render json: {status: "complete", comment: comment}
        else
            render json: {status: "failed", errors: comment.errors.objects.first.full_message}
        end
    end

    def destroy
        delete_stack = []
        comment = ReviewComment.find_by(id: comments_param[:id])

        if !comment
            render json: {status: "failed", parent: parent, error: "Comment does not exist"}
            return nil
        end

        destroyed_comments = {};

        replies = ReviewComment.where(parent: comment.id)
        delete_stack.push(comment,*replies)

        delete_stack.each do |item|
            item_id = item.id
            destroyed_comments[item_id] = {
                id: item.id,
                top_comment: item.top_comment,
                comment_type: item.comment_type,
                user_id: item.user_id,
                parent: item.parent,
                comment: item.comment,
            }
            item.destroy
            check = ReviewComment.find_by(id: comments_param[:id])

            if check
                render json: {status: "failed", parent: parent, error: "Did not delete all comments. id: #{item.id} count not be deleted"}
                return nil
            end
        end

        render json: {status: "complete", comments: destroyed_comments}

    end

    def comments_param
        params.permit(:id,:comment,:review_id,:user_id,:top_comment,:comment_type,:parent)
    end

    def find_comment
        comment = ReviewComment.find_by(id: comments_param[:id])
    end

    def find_review
        review = Review.find_by(id: comments_param[:review_id])
    end

    def comment_attrs(comment = nil) 
        comment_type = comments_param[:comment_type]
        parent = comments_param[:parent]
        
        if comment_type == "reply"
            parent = ReviewComment.find_by(id: comments_param[:parent])
            top_comment = parent.id
        elsif comment_type == "comment"
            parent = Review.find_by(id: comments_param[:parent])
            top_comment = ReviewComment.last.id + 1
        end

        if !parent
            render json: {status: "failed", parent: parent, error: "Review or Comment does not exist"}
            return nil
        end

        review_id = comments_param[:review_id].to_i
        comment = comments_param[:comment]
        user_id = comments_param[:user_id]
        parent = parent.id

        components = {
            review_id: review_id,
            comment: comment,
            user_id: user_id,
            comment_type: comment_type,
            parent: parent,
            top_comment: top_comment
        }

        components
    end
end
