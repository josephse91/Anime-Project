class Api::LikesController < ApplicationController
    def index
        likes = Like.all

        if !likes
            render json: {status: "failed", error: "Likes could not be found"}
            return
        end

        render json: {status: "complete",likes: likes }
    end

    def create
        action = ActiveSupport::JSON.decode(like_params[:like_action])
        user = action["action_user"]
        item_type = action["target_item"]
        item_id = action["id"]
        upvote = action["action"] == "like"
        downvote = action["action"] == "unlike"

        like = Like.new({
            user: user,
            item_type: item_type,
            item_id: item_id,
            upvote: upvote,
            downvote: downvote
        })

        if like.invalid?
            render json: {status: "failed", error: like.errors.objects.first.full_message}
            return
        end

        like.save
        render json: {status: "complete", like: like}
    end

    def show
        item = like_params[:id]
        item_type = like_params[:item_type]

        where_query = ['item_type= ? AND item_id = ?',item_type,item]
        likes = Like.where(where_query)

        if likes.length == 0
            render json: {status: "failed", error: "likes could not be found for object"}
            return
        end

        render json: {status: "complete", likes: likes}
    end

    def update
        action = ActiveSupport::JSON.decode(like_params[:like_action])
        user = action["action_user"]
        item_type = action["target_item"]
        item_id = like_params[:id]
        upvote = action["action"] == "like"
        downvote = action["action"] == "unlike"


        where_text = 'likes.user= ? AND item_type= ? AND item_id = ?'
        where_query = [where_text,user,item_type,item_id]
        like = Like.where(where_query).take

        if !like
            render json: {status: "failed", error: "Could not find like to edit"}
            return
        end

        like.upvote = upvote
        like.downvote = downvote

        if like.invalid?
            render json: {status: "failed", error: like.errors.object.first.full_message}
            return
        end

        like.save
        render json: {status: "complete", like: like}
    end

    def destroy
        action = ActiveSupport::JSON.decode(like_params[:like_action])
        user = action["action_user"]
        item_type = action["target_item"]
        item_id = like_params[:id]
        
        where_text = 'likes.user= ? AND item_type= ? AND item_id = ?'
        where_query = [where_text,user,item_type,item_id]
        like = Like.where(where_query).take

        if !like
            render json: {status: "failed", error: "Could not find like to edit"}
            return
        end

        deleted_like = like
        like.destroy

        if !like.destroyed?
            render json: {status: "failed", error: like.errors.objects.first.full_message}
            return
        end

        render json: {status: "complete", action: "neutral", like: deleted_like}
    end

    def like_params
        params.permit(:id,:like_action, :item_type)
    end
end
