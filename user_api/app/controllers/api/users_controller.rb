class Api::UsersController < ApplicationController
    
    def create
        create_params = user_params.select {|key,value| key != "password" && value}
        @user = User.new(create_params)
        
        @user.password(user_params[:password]) if @user

        if @user.save
            render json: {status: "complete"}
        else
            error = @user.errors.messages.length > 0 ? @user.errors.messages : "Either the username or password is invalid"
            render json: {status: "failed", error: error}
        end
    end

    def show
        @user = User.find_by(username: user_params[:id])

        if !@user
            render json: {status: "failed", error: "no existing user"}
            return
        end




    end

    def update
        @user = User.find_by(username: user_params[:id])
        if !@user
            render json: {status: "failed", error: "no existing user"}
            return
        end
        
        if user_params[:new_username]
            return if !check_password(@user)
            @user.update(username: user_params[:new_username])
        elsif user_params[:new_password]
            return if !check_password(@user)
            @user.password(user_params[:new_password])
            @user.save
        elsif !user_params[:password]
            @user.update(user_params)
        end

        render json: {status: "complete"}
    end

    def destroy
        if !current_user
            render json: {status: "failed", error: "not signed in"}
        end

        @user = User.find_by(session_token: user_params[:session_token_input])

        if !@user
            render json: {status: "failed", error: "not signed in - Invalid Session token"}
            return
        end

        if !user_params[:password] || !@user.is_password?(user_params[:password])
            render json: {status: "failed",error: "Invalid Password"}
            return
        end

        @user.destroy

        render json: {status: "complete"}

    end

    def user_params
        params.permit(:id,:username,:password,:genre_preference,:go_to_motto,:user_grade_protocol,:rooms,:peers,:requests,:new_username,:new_password,:session_token_input)
    end

    def check_password(user)
        password = user_params[:password] && @user.is_password?(user_params[:password])

        if !password
            render json: {status: "failed", error: "Incorrect Password"}
        end
        password
    end
end