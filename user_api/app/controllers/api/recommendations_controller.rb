class Api::RecommendationsController < ApplicationController

    def index
        recs = Recommendation.all

        if !recs
            render json: {status: "failed", error: "Could not find any recommendations"}
            return
        end

        render json: {status: "complete", recommendations: recs}
    end

    def create
        user_id = find_user
        return if !user_id

        referral_id = find_referrer
        return if !referral_id

        show = referrer_eligibility(user_id,referral_id)

        referrer_recs = Recommendation.where(user_id: user_id.username, referral_id: referral_id.username, accepted: false)

        if referrer_recs.length > 3
            render json: {status: "failed", error: "You can only send a maximum of 3 recommendations"}
            return
        end

        rec = Recommendation.new({
            user_id: user_id.username,
            show: show,
            referral_id: referral_id.username
        })

        notifications = []

        if rec.invalid?
            render json: {status: "failed", error: rec.errors.objects.first.full_message}
            return
        end

        rec.save
        notification = {
            id: rec.id,
            recipient: user_id.username,
            action: "recommendation sent",
            action_user: referral_id.username,
            target_item: "recommendation",
            show: show
        }
        notifications.push(notification)

        render json: {
            status: "complete", 
            recommedation: rec, 
            notifications: notifications
        }
    end

    def show
        user_id = find_user
        return if !user_id

        recs = Recommendation.where(user_id: user_id.username)
        render json: {status: "complete", recommendations: recs}
    end

    # need to create the update controller. This will allow the person that received the recommendation to 

    def destroy
        user_id = find_user&.username
        return if !user_id

        show = rec_params[:show]

        rec = Recommendation.where(user_id: user_id, show: show).take

        if !rec
            render json: {status: "failed", error: "Could not find the recommendation"}
            return
        end

        deleted_rec = rec

        rec.destroy

        if !rec.destroyed?
            render json: {status: "failed", error: rec.errors.objects.first.full_message}
            return
        end

        render json: {status: "complete", recommendation: deleted_rec}
    end

    def find_user
        input_user = rec_params[:user_id] || rec_params[:id]
        user = User.find_by(username: input_user)

        if !user
            render json: {status: "failed", error: "Could not find User"}
            return
        end

        user
    end

    def find_referrer
        user = User.find_by(username: rec_params[:referral_id])

        if !user
            render json: {status: "failed", error: "Could not find Referrer"}
            return
        end

        user
    end

    def referrer_eligibility(user_id,referrer)
        show = rec_params[:show]
        users = "(reviews.user = '#{user_id.username}' OR reviews.user = '#{referrer.username}')"
        show_query = "'#{show}'"

        sql = <<-SQL
        SELECT *
        FROM reviews
        WHERE #{users} AND reviews.show = #{show_query}
        SQL

        review = Review.find_by_sql(sql)[0]

        if !review
            render json: {status: "failed", error: "You are not eligible to leave a recommendation on an anime you haven't reviewed"}
            return
        end

        if review.user == user_id.username
            render json: {status: "failed", error: "User has already watched this anime"}
            return
        end

        # need another conditional for people that already have a referral

        already_watched =  Review.where(user: user_id.username, show: show).take

        review.show
    end

    def rec_params
        params.permit(:id,:user_id,:show,:referral_id,)
    end

end
