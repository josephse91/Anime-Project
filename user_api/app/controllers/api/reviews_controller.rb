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
        components_hash = review_attrs
        return if !components_hash

        components = components_hash[:components]
        user = components_hash[:user]

        

        @review = Review.new(components)

        if !@review.valid?
            render json: {status: "failed", errors: @review.errors.objects.first.full_message}
            return
        end

        @review.save
        render json: {status: "complete", user: user, review: @review}
    end

    def add_review_to_rooms
        hash = find_show
        return if !hash

        user = hash[:user]
        review = hash[:review]
        show = hash[:show]
        review_exists_in_room = true

        rooms = user.rooms.map do |room,enter_date|
            current_room = Room.find_by(room_name: room)
    
            if current_room.shows[show]
                current_room.shows[show] += 1
            else
                current_room.shows[show] = 1
                review_exists_in_room = false
            end
            current_room.save
            current_room
        end

        render json: {
            status: "complete", 
            user: user,
            review: review, 
            rooms: rooms,
            review_exists_in_room: review_exists_in_room
        }
    end

    def show
        # get the specific review of a specific user
        review = find_show[:review]
        return if review.nil?

        render json: {status: "complete", review: review}
    end

    def update
        return if !review_attrs

        components = review_attrs[:components]
        review = review_attrs[:review]

        return if !components || !review

        if review.update(components)
            render json: {status: "complete", review: review}
        else 
            render json: {status: "failed", errors: review.errors.objects.first.full_message}
        end
    end

    def destroy
        review = find_show[:review]
        return if review.nil?

        comments = ReviewComment.where(review_id: review.id)
        review.destroy
        
        render json: {status: "complete", review: review, comments: comments}
    end

    #helper functions
    def review_params
        params.permit(:id,:user_id, :current_user, :show,:rating,:amount_watched,:highlighted_points,:overall_review,:referral_id,:watch_priority,:in_network,:range, :likes, :review_id)
    end

    def find_user
        input_user =  review_params[:user_id]
        user = User.find_by(username: input_user)

        if !user && !review_params[:current_user]
            render json: {status: "failed", user: user,error: "Invalid user"}
            return
        end

        user
    end

    def current_user
        user_input =  review_params[:current_user]
        current_user = User.find_by(username: user_input)

        if !current_user
            render json: {status: "failed", user: current_user,error: "Could not find current user"}
            return
        end

        current_user
    end

    def find_show
        user = find_user || current_user
        return nil if user.nil?

        show = review_params[:id] || review_params[:review_id]
        return {user: user, show: review_params[:show]} if !show

        review = Review.where([
            "reviews.user = ? and show = ?",
            user.username,
            show
            ]).take

        if review_params[:id] && !review
            render json: {status: "failed", review: review,show: show, user: user, error: "This user has not reviewed this show"}
            return
        end

        {user: user, review: review, show: show}
    end

    def review_attrs
        client_user = current_user || find_user
        return if !client_user
        
        review_hash = find_show
        return if !review_hash

        show = review_hash[:show]
        review = review_hash[:review]
        user = review_hash[:user]
        return if !review && review_params[:id]

        likes_hash = review_params[:id] ? adjust_likes(review) : {}
        likes = likes_hash[:likes]
        return if likes_hash[:action]
        
        if review && review.user != client_user.username
            render json: {status: "failed", error: "User not authorized to edit this review"}
            return
        end

        rating = review_params[:rating] || review&.rating
        amount_watched = review_params[:amount_watched] || review&.amount_watched
        hps = review_params[:highlighted_points] || review&.highlighted_points
        overall_review = review_params[:overall_review] || review&.overall_review
        referral_id = review_params[:referral_id] || review&.referral_id
        wp = review_params[:watch_priority] || review&.watch_priority

        components = {
            user: user.username,
            show: show,
            rating: rating
        }

        components[:amount_watched] = amount_watched
        components[:highlighted_points] = hps
        components[:overall_review] = overall_review
        components[:referral_id] = referral_id
        components[:watch_priority] = wp
        likes ? components[:likes] = likes : nil

        {review: review, user: client_user, components: components}
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

    def adjust_likes(review)
        action_hash = review_params[:likes]
        return {action: nil, likes: review.likes}if !action_hash

        notifications = []
        action = ActiveSupport::JSON.decode(action_hash)
        # review_check = Review.find_by(id: action["review_id"])

        # if review != review_check
        #     render json: {status: "failed", error: "Review not matching parameters"}
        #     return
        # end

        like_count = review.likes
        user = User.find_by(username: action["user"])
        net = action["net"]
        target = action["target"]

        if net < target
            review.likes = like_count + 1
            event = "like"
        elsif net > target
            review.likes = like_count - 1
            event = "unlike"
        end

        review.save

        data = {
            id: review.id,
            recipient: review.user,
            action: event,
            action_user: user.username,
            target_item: "Review"
        }
        event == "like" ? notifications.push(data) : nil
        render_obj = {status: "complete", event: event, review: review}
        notifications.length > 0 ? render_obj[:notifications] = notifications : nil

        render json: render_obj

        {action: event, review: review}
    end
end
