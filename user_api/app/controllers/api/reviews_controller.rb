class Api::ReviewsController < ApplicationController

    def index
        reviews = Review.all

        render json: {status: "complete", reviews: reviews}
    end
    
    def user_index
        username = find_user
        return if username.nil?
        reviews = Review.where(user: username).order(rating: :desc, user: :asc)

        render json: {status: "complete", reviews: reviews}
    end

    def create
        username = find_user
        return if username.nil?

        components = review_attrs

        @review = Review.new(components)

        if (@review.save) 
            {status: "complete", review: @review}
        else 
            render json: {status: "failed", errors: @review.errors.objects.first.full_message}
        end

    end

    def show
        # get the specific review of a specific user
        review = find_show
        return if review.nil?

        render json: {status: "complete", review: review}
    end

    def update
        review = find_show
        return if review.nil?

        components = review_attrs(review)
        review.update(components)

        if (review.save) 
            render json: {status: "complete", review: review}
        else 
            render json: {status: "failed", errors: review.errors.objects.first.full_message}
        end
    end

    def destroy
        review = find_show(username)
        return if review.nil?
    end

    #helper functions
    def review_params
        params.permit(:id,:user,:user_id,:show,:rating,:amount_watched,:highlighted_points,:overall_review,:referral_id,:watch_priority)
    end

    def find_user
        input_user = review_params[:user_id] || review_params[:user]
        user = User.find_by(username: input_user)

        if !user
            render json: {status: "failed", user: user,error: "Invalid user"}
            return
        end

        user.username
    end

    def find_show
        username = find_user
        return nil if username.nil?

        show = review_params[:id] || review_params[:show]
        review = Review.where(["reviews.user = ? and show = ?",username,show]).take

        if !review
            render json: {status: "failed", error: "No review for this show"}
        end

        review
    end

    def review_attrs(review = nil)
        user = review_params[:user_id] || review_params[:user]
        show = review_params[:id] || review_params[:show]
        rating = review_params[:rating] || review&.rating
        amount_watched = review_params[:amount_watched] || review&.amount_watched
        hps = review_params[:highlighted_points] || review&.highlighted_points
        overall_review = review_params[:overall_review] || review&.overall_review
        referral_id = review_params[:referral_id] || review&.referral_id
        wp = review_params[:watch_priority] || review&.watch_priority

        components = {
            user: user,
            show: show,
            rating: rating.to_i,
            amount_watched: amount_watched,
            highlighted_points: hps,
            overall_review: overall_review,
            referral_id: referral_id,
            watch_priority: wp.to_i
        }
    end
end
