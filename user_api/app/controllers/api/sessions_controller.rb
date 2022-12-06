class Api::SessionsController < ApplicationController

    def create
        user = User.find_by_credentials(
          params[:username],
          params[:password]
        )
    
        if user.nil?
          render json: {status: "failed", error: "Invalid Credentials"}
    
        else
          login_user!(user)
          render json: {status: "complete", current_session: session[:session_token]}
        end
    end
    
    def destroy
        current_user.update(session_token: nil)
        session[:session_token] = nil

        render json: {status: "complete", current_user: session[:session_token]}
    end

    def user_params
        params.permit(:id,:username,:password)
    end

end
