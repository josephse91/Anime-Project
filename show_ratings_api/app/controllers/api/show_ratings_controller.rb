class Api::ShowRatingsController < ApplicationController

    def index
        shows = ShowRating.all

        if !shows
            render json: {status: "failed", error: shows.errors.objects.first.full_message}
            return
        end

        render json: {status: "complete", shows: shows}
    end

    def room_show_index
        room = show_params[:room_id]
        sql_room = "'" + room + "'"
        
        if !room
            render json: {status: "failed", error: "No room has been provided"}
        end

        sql = <<-SQL
        SELECT *, total_points / number_of_reviews AS Average_grade
        FROM show_ratings
        WHERE room_id = #{sql_room}
        ORDER BY Average_grade DESC
        SQL

        shows = ShowRating.find_by_sql(sql)

        render json: {status: "complete", shows: shows}
    end

    def create
        create_array = []
        if show_params[:review]
            review = ActiveSupport::JSON.decode(show_params[:review])
            rooms = ActiveSupport::JSON.decode(show_params[:rooms])
            create_objects = rooms.map do |room|
                {
                    room_id: room,
                    show_title:review["show"],
                    reviewers: {review["user"] => review["rating"]},
                    total_points: review["rating"],
                    number_of_reviews: 1
                }
            end
            create_array.push(create_objects)
        else
            reviews = ActiveSupport::JSON.decode(show_params[:reviews])
            room = show_params[:room_id]
            create_objects = reviews.map do |review|
                {
                    room_id: room,
                    show_title:review["show"],
                    reviewers: {review["user"] => review["rating"]},
                    total_points: review["rating"],
                    number_of_reviews: 1
                }
            end
            create_array.push(create_objects)
        end

        new_shows = ShowRating.create(create_array)

        if !new_shows
            render json: {status: "failed", error: create_objects}
            return
        end

        render json: {status: "complete", show: new_shows}
    end

    def update
        show_ratings = nil
        update_hash = {}
        action = show_params[:show_action]

        if show_params[:review]
            review = ActiveSupport::JSON.decode(show_params[:review])
            user = review["user"]
            rooms = ActiveSupport::JSON.decode(show_params[:rooms])
            room_names = rooms.map { |room| room }

            show_ratings = ShowRating.where(room_id: room_names).where(show_title: review["show"])

            show_ratings.each do |rating|
                current_total_points = rating.total_points
                current_reviewers = rating.reviewers
                new_point_total = nil
                
                if action == "add review"
                    rating.reviewers[user] = review["rating"]
                    new_point_total = current_total_points + review["rating"]
                    rating.number_of_reviews += 1
                elsif action == "edit review"
                    old_rating = current_reviewers[user]
                    rating.reviewers[user] = review["rating"]
                    new_point_total = current_total_points + review["rating"] - old_rating
                elsif action == "delete review"
                    old_rating = rating.reviewers[user]
                    rating.reviewers.delete(user)
                    new_point_total = current_total_points - old_rating
                    rating.number_of_reviews -= 1
                end

                update_hash[rating.id] = {
                    "reviewers" => rating.reviewers,
                    "total_points" => new_point_total,
                    "number_of_reviews" => rating.number_of_reviews
                }
            end
        else
            reviews = ActiveSupport::JSON.decode(show_params[:reviews])
            room = show_params[:room_id]

            shows = {}
            reviews.each { |review| shows[review["show"]] = review["rating"]}
            user = reviews[0]["user"]
            show_ratings = ShowRating.where(room_id: room).where(show_title: shows.keys)

            show_ratings.each do |rating|
                current_total_points = rating.total_points
                current_reviewers = rating.reviewers
                new_point_total = nil
                
                if action == "member added"
                    rating.reviewers[user] = shows[rating.show_title]
                    new_point_total = current_total_points + shows[rating.show_title]
                    rating.number_of_reviews += 1
                elsif action == "member removed"
                    if !current_reviewers[user]
                        render json: {status: "failed", error: "Has not rated this show"}
                        return
                    end
                    old_rating = current_reviewers[user]
                    rating.reviewers.delete(user)
                    new_point_total = current_total_points - old_rating
                    rating.number_of_reviews -= 1
                end

                update_hash[rating.id] = {
                    "reviewers" => rating.reviewers,
                    "total_points" => new_point_total,
                    "number_of_reviews" => rating.number_of_reviews
                }
            end
        end

        new_shows = ShowRating.update(update_hash.keys,update_hash.values)

        if !new_shows
            render json: {status: "failed", error: update_hash}
            return
        end

        render json: {status: "complete", show: new_shows}
    end

    def destroy
        ids = []

        if show_params[:review]
            review = ActiveSupport::JSON.decode(show_params[:review])
            rooms = ActiveSupport::JSON.decode(show_params[:rooms])

            show_ratings = ShowRating.where(room_id: rooms).where(show_title: review["show"])

            show_ratings.each { |show| ids.push(show.id)}
            
        else
            reviews = ActiveSupport::JSON.decode(show_params[:reviews])
            user = reviews[0]["user"]
            room = show_params[:room_id]

            shows = {}
            reviews.each { |review| shows[review["show"]] = review["rating"]}

            show_ratings = ShowRating.where(room_id: room).where(show_title: shows.keys)

            show_ratings.each { |show| ids.push(show.id)}
        end

        new_shows = ShowRating.delete(ids)

        if !new_shows
            render json: {status: "failed", error: ids}
            return
        end

        render json: {status: "complete", shows: ids}

    end

    def show_params
        params.permit(:id,:mal_show_id,:show_title,:room_id,:reviewers,:total_points, :review, :reviews,:rooms,:user, :show_action)
    end

end
