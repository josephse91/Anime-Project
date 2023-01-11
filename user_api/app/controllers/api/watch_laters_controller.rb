class Api::WatchLatersController < ApplicationController
    def index
        watch_laters = WatchLater.all

        if !watch_laters
            render json: {status: "failed", error: "Could not find the watch laters"}
            return
        end

        render json: {status: "complete", watch_laters: watch_laters}
    end

    def create
        user_id = find_user&.username
        return if !user_id

        show = watch_later_params[:show]

        recommendation = find_referrer(user_id,show)

        watch_later = WatchLater.new({
            user_id: user_id,
            show: show
        })

        recommendation ? watch_later.referral_id = recommendation.referral_id : nil

        if watch_later.invalid?
            render json: {status: "failed", error: watch_later.errors.objects.first.full_message}
            return
        end

        if recommendation
            recommendation.accepted = true
            recommendation.save
        end

        watch_later.save
        render json: {status: "complete", watch_later: watch_later}
    end

    def show
        user_id = find_user
        return if !user_id

        watch_laters = WatchLater.where(user_id: user_id.username)
        render json: {status: "complete", watch_laters: watch_laters}
    end

    def destroy
        user_id = find_user&.username
        return if !user_id

        show = watch_later_params[:show]

        watch_later = WatchLater.where(user_id: user_id, show: show).take

        if !watch_later
            render json: {status: "failed", error: "Could not find the watch later"}
            return
        end

        render_obj = {status: "complete"}

        if watch_later.referral_id
            r_id = watch_later.referral_id
            original_rec = Recommendation.where(user_id: user_id, show: show, referral_id: r_id).take

            original_rec.destroy
            render_obj[:message] = "Anime recommendation also deleted"
            render_obj[:recommendation] = original_rec
        end

        deleted_watch_later = watch_later
        render_obj[:watch_later] = deleted_watch_later

        watch_later.destroy

        if !watch_later.destroyed?
            render json: {status: "failed", error: watch_later.errors.objects.first.full_message}
            return
        end

        render json: render_obj
    end

    def find_user
        input_user = watch_later_params[:user_id] || watch_later_params[:id]
        user = User.find_by(username: input_user)

        if !user
            render json: {status: "failed", error: "Could not find User"}
            return
        end

        user
    end

    def find_referrer(user,show)
        rec = Recommendation.where(user_id: user, show: show).take
    end

    def watch_later_params
        params.permit(:id,:user_id,:show)
    end
end
