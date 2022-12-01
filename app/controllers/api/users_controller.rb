class Api::UsersController < ApplicationController
    
    def create
        create_params = user_params.select {|key,value| key != "password" && value}
        @user = User.new(create_params)
        
        @user.password(user_params[:password]) if @user

        if @user.save
            render json: {status: "complete"}
        else
            error = @user.errors.messages.length > 0 ? @user.errors.messages : "Either the username or password is incorrect"
            render json: {status: "failed", error: error}
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
