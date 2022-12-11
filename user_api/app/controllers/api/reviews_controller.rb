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

        components = {
            user: review_params[:user],
            show: review_params[:show],
            rating: review_params[:rating].to_i,
            amount_watched: review_params[:amount_watched],
            highlighted_points: review_params[:highlighted_points],
            overall_review: review_params[:overall_review],
            referral_id: review_params[:referral_id],
            watch_priority: review_params[:watch_priority]
        }

        @review = Review.new(components)

        if (@review.save) 
            render :create
        else 
            render json: {status: "failed", errors: @review.errors.objects.first.full_message}
        end

    end

    def show
        # get the specific review of a specific user
        username = find_user
        return if username.nil?

        show = review_params[:id]
        review = Review.where(["reviews.user = ? and show = ?",username,show]).take

        if !review
            render json: {status: "failed", error: "No review for this show"}
            return
        end

        render json: {status: "complete", reviews: review}
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
end
