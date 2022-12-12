class Api::ReviewsController < ApplicationController

    def index
        where_array = where_filter

        if review_params[:in_network] === "true" || review_params[:range]
            reviews = Review.where(where_array).order(rating: :desc)
            render json: {status: "complete",type: "peers", reviews: reviews}
        else
            reviews = Review.all.order(rating: :desc);
            render json: {status: "complete",type: "all", reviews: reviews}
        end

    end
    
    def user_index
        username = find_user.username
        return if username.nil?
        reviews = Review.where(user: username).order(rating: :desc, user: :asc)

        render json: {status: "complete", reviews: reviews}
    end

    def create
        username = find_user.username
        return if username.nil?

        components = review_attrs

        @review = Review.new(components)

        if (@review.save) 
            render json: {status: "complete", review: @review}
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
        review = find_show
        return if review.nil?

        comments = ReviewComment.where(review_id: review.id)
        review.destroy
        
        render json: {status: "complete", review: review, comments: comments}
    end

    #helper functions
    def review_params
        params.permit(:id,:user,:user_id,:show,:rating,:amount_watched,:highlighted_points,:overall_review,:referral_id,:watch_priority,:in_network,:range, :change_like)
    end

    def find_user
        input_user = review_params[:user_id] || review_params[:user]
        user = User.find_by(username: input_user)

        if !user
            render json: {status: "failed", user: user,error: "Invalid user"}
            return
        end

        user
    end

    def find_show
        username = find_user.username
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
        likes = review_params[:change_likes] || review&.likes

        components = {
            user: user,
            show: show,
            rating: rating.to_i,
            amount_watched: amount_watched,
            highlighted_points: hps,
            overall_review: overall_review,
            referral_id: referral_id,
            watch_priority: wp.to_i,
            likes: likes.to_i
        }
    end

    def query_peers_array(user)
        peer_array = ""
        user_peers = user.peers.keys.map {|key| key.to_s}

        if user_peers.length <= 0
            render json: {status: "complete", reviews: []}
            return ""
        end

        peer_array += "("
        user_peers.each.with_index do |peer,idx|
            peer_array += "'#{peer}',"
            if idx == user_peers.length - 1
                peer_array[-1] = ")"
            end
        end
    
        peer_array
    end

    def where_filter
        network = review_params[:in_network]
        range = nil 
        if review_params[:range]
            range = ActiveSupport::JSON.decode(review_params[:range]) 
        end
        where_array = [""]

        if network === "true"
            user = find_user
            return if user.nil?

            peers_query = "reviews.user IN " + query_peers_array(user)
            
            where_array[0] += peers_query
        end

        if range
            range_query = "reviews.rating BETWEEN ? AND ?"
            where_array.push(range["bottom"],range["top"])
            
            if where_array[0] != ""
                where_array[0] += " AND "
            end

            where_array[0] += range_query
        end

        where_array
    end
end
