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

    def show
        # get the specific review of a specific user
        username = find_user
        show = review_params[:id]
        review = Review.where(["reviews.user = ? and show = ?",username,show]).take

        render json: {status: "complete", reviews: review}
    end

    def review_params
        params.permit(:user_id,:id)
    end

    def find_user
        input_user = review_params[:user_id]
        user = User.find_by(username: input_user)

        if !user
            render json: {status: "failed", user: user,error: "Invalid user"}
            return
        end

        user.username
    end
end
