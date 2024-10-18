class Api::ReviewsController < ApplicationController

    def index
        where_array = where_filter
        active_user = current_user
        network_filter = review_params[:in_network]
        range_filter = review_params[:range]

        if active_user && network_filter
            reviews = Review.where(where_array).order(rating: :desc)
            render json: {status: "complete",type: "peers", reviews: reviews}
        elsif !active_user && network_filter
            reviews = Review.all.order(rating: :desc);
            render json: {status: "complete",type: "all", reviews: reviews}
        else
            reviews = Review.all.order(rating: :desc);
            render json: {status: "complete",type: "all", reviews: reviews}
        end
    end
    
    def user_index
        user = find_user || current_user
        return if !user
        
        reviews = Review.where(user: user.username).order(rating: :desc, user: :asc)

        render json: {status: "complete", reviews: reviews}
    end

    def create
        components_hash = review_attrs
        return if !components_hash

        components = components_hash[:components]
        user = components_hash[:user]
        notification = components_hash[:notifications]

        @review = Review.new(components)

        if !@review.valid?
            render json: {status: "failed", review: @review, errors: @review.errors.objects.first.full_message}
            return
        end

        @review.save

        render_obj = {
            status: "complete", 
            user: user, 
            review: @review, 
            action: "add review"
        }

        notifications = []
        if notification
            notifications.push(notification)
            render_obj[:notifications] = notifications 
        end

        render json: render_obj
    end

    def add_review_to_rooms
        action = review_params[:review_action]
        user = find_user || current_user
        review = ActiveSupport::JSON.decode(review_params[:show_object])
        show = review["show"]
        
        rooms_to_add_show = []
        rooms_to_edit_show = []
        rooms_to_delete_show = []

        rooms = user.rooms.map do |room,enter_date|
            current_room = Room.find_by(room_name: room)
    
        if !current_room.shows[show] && action == "add review"
            current_room.shows[show] = 1
            rooms_to_add_show.push(room)
        elsif current_room.shows[show] == 1 && action == "delete review"
            rooms_to_delete_show.push(room)
            current_room.shows.delete(show)    
        elsif current_room.shows[show] && current_room.shows[show] >= 1
                if action == "delete review"
                    rooms_to_edit_show.push(room)
                    current_room.shows[show] -= 1
                elsif action == "edit review"
                    rooms_to_edit_show.push(room)
                elsif action == "add review"
                    rooms_to_edit_show.push(room)
                    current_room.shows[show] += 1
                end
            end

            if current_room.invalid?
                render json: {status: "failed", error: current_room.errors.objects.first.full_message}
                return
            end

            current_room.save
            current_room
        end

        render json: {
            status: "complete", 
            user: user,
            review: review, 
            rooms: rooms,
            action: action,
            rooms_to_add_show: rooms_to_add_show,
            rooms_to_edit_show: rooms_to_edit_show,
            rooms_to_delete_show: rooms_to_delete_show
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
            render json: {status: "complete", review: review, action: "edit review"}
        else 
            render json: {status: "failed", errors: review.errors.objects.first.full_message}
        end
    end

    def destroy
        if !current_user
            render json: {status: "failed", error: "User is not owner of review"}
            return
        end
        
        review_hash = find_show
        review = review_hash ? review_hash[:review] : nil

        # if there is no review by this user, return. Error will be rendered already
        return if !review

        review_copy = review

        comments = ReviewComment.where(review_id: review.id)
        # The review_comments are deleted automatically due to the model validations
        review.destroy

        if !review.destroyed?
            render json: {status: "failed", error: review.errors.objects.first.full_message}
            return
        end
        
        render json: {status: "complete", action: "delete review", review: review_copy, comments: comments}
    end

    #helper functions
    def review_params
        params.permit(:id,:user_id, :show,:rating,:amount_watched,:highlighted_points,:overall_review,:referral_id,:watch_priority,:in_network,:range, :likes, :review_id, :review_action, :show_object)
    end

    def find_user
        input_user =  review_params[:user_id]
        user = User.find_by(username: input_user)

        if !user
            render json: {status: "failed", user: user,error: "Invalid user"}
            return
        end

        user
    end

    def current_reviewer
        if !current_user
            render json: {status: "failed", user: current_user,error: "User Not signed in"}
        end

        current_user
    end

    def find_show
        # prioritizes a target user before the current user
        user = find_user || current_user
        return nil if user.nil?

        #id is used as a wildcard for the typical /api/reviews/ requests
        #review_id is used as a wildcard in the request to add reviews to all applicable rooms
        show = review_params[:id] || review_params[:review_id]
        # if there is no review wildcard, there will be a show input instead of searched
        return {user: user, show: review_params[:show]} if !show

        review = Review.where([
            "reviews.user = ? and show = ?",
            user.username,
            show
            ]).take

        if (review_params[:id] || review_params[:review_id]) && !review
            render json: {status: "failed", review: review,show: show, user: user, error: "This user has not reviewed this show"}
            return
        end

        {user: user, review: review, show: show}
    end

    def review_attrs
        output = {}
        client_user = current_user || find_user
        return if !client_user
        
        review_hash = find_show
        # return if the inputted show was not reviewed by the target user/current user
        return if !review_hash

        show = review_hash[:show]

        review = review_hash[:review]
        output[:review] = review
        output[:user] = client_user
        user = review_hash[:user]
        # If there is intention to capture an existing review with the wildcards but there is no show review, it must return
        return if !review && (review_params[:id] || review_params[:review_id])

        likes_hash = review_params[:id] ? adjust_likes(review,client_user) : {}
        likes = likes_hash[:likes]
        return if likes_hash[:action]
        
        #everything beyond this point requires the review user being the current_user
        if review && review.user != client_user.username
            render json: {status: "failed", error: "User not authorized to edit this review"}
            return
        end

        components = {}

        # fields required to create the review for the first time
        if !review_params[:id]
            components[:user] = user.username
            components[:show] = show
        end

        #fields capable of being editted
        existing_highlights = review ? review.highlighted_points : [];
        new_highlight = [review_params[:highlighted_points]] || []

        components[:rating] = review_params[:rating] || review.rating
        components[:highlighted_points] = [*existing_highlights,*review_params[:highlighted_points]]

        overall_review = review ? review.overall_review : nil
        watch_priority = review ? review.watch_priority : 0
        amount_watched = review ? review.watch_priority : nil

        components[:overall_review] = review_params[:overall_review] || overall_review
        components[:watch_priority] = review_params[:watch_priority] || watch_priority
        components[:amount_watched] = review_params[:amount_watched] || amount_watched

        #recommendation acceptance is slightly broken. There is no indicator that a recommendation has been addressed. 
        !review ? recommendation = active_recommendation(client_user,show) : nil
        
        if recommendation
            recommendation.accepted = 1
            recommendation.save

            p "recommendation logic works"

            output[:notifications] = {
                id: recommendation.id,
                recipient: recommendation.referral_id,
                action: "accepted recommendation",
                action_user: user.username,
                show: show,
                target_item: "Recommendation"
            }
            components[:referral_id] = recommendation.referral_id 
        end

        output[:components] = components  
        output
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
            user = current_user
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

    def active_recommendation(user,show)
       # The first accepted referral will have the referrer placed in the referral id upon a review creation
        accepted_rec = Recommendation.where(user_id: user.username, show: show, accepted: 1).order(created_at: :asc).take

        # if someone rejects a recommendation within the last month but they end up watching the show, the first referrer will get credit for the referral
        rejected_rec = Recommendation.where("user_id = ? AND show = ? AND accepted = ? AND created_at > ?", user.username, show, -1, 1.months.ago)
        .order(created_at: :asc)
        .take

        accepted_rec || rejected_rec
    end

    def adjust_likes(review,client_user)
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
        net = action["net"]
        target = action["target"]

        if net < target
            review.likes = like_count + 1
            event = "like"
        elsif net > target
            review.likes = like_count - 1
            event = "neutral"
        end

        review.save

        data = {
            id: review.id,
            recipient: review.user,
            action: event,
            net: net,
            action_user: client_user.username,
            show: review.show,
            target_item: "Review"
        }
        event == "like" ? notifications.push(data) : nil
        render_obj = {status: "complete", action: event, like_action: data, review: review}
        notifications.length > 0 ? render_obj[:notifications] = notifications : nil

        render json: render_obj

        {action: event, review: review}
    end
end
