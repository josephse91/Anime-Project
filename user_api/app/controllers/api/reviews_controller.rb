class Api::ReviewsController < ApplicationController

    def user_index
        user = User.find_by(username: :user_id)

        if !user
            render json: {status: "failed", error: "Invalid user"}
        end

        username = user.username
        reviews = Review.where(user: username)

        render json: {status: "complete", reviews: reviews}
    end
end
