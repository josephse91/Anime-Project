class Api::UsersController < ApplicationController
    
    def create
        @user = User.new(user_params)

        if @user.save
            render json: {status: "complete"}
        else
            render json: {status: "failed", error: "Either the username or password is incorrect"}
        end
    end

    def update
        @user = User.find_by(username: user_params[:username])
        if !@user
            render json: {status: "failed", error: "no existing user"}
            return
        end

        if user_params[:password] && !@user.is_password?(user_params[:password])
            render json: {status: "failed", error: "Incorrect Password"}
            return
        end

        case
            when user_params[:new_username] != nil
                @user.update(username: user_params[:new_username])
            when user_params[:new_password] != nil
                @user.password(user_params[:new_password])
                @user.save
            else
                @user.update(user_params)
        end

        render json: {status: "complete"}
    end

    def destroy
        @user = User.find_by(username: user_params[:username])

        if !user_params[:password] || !@user.is_password?(user_params[:password])
            render json: {status: "failed",error: "Invalid Password"}
            return
        end

        @user.destroy

        rend json: {status: "complete"}

    end


    def user_params
        params.permit(:id,:username,:password,:genre_preference,:go_to_motto,:user_grade_protocol,:rooms,:peers,:requests,:new_username,:new_password)
    end

end
