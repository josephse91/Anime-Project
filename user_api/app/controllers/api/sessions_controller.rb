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
          render json: {
            status: "complete",
            user: user,
            ad_session_token: user.session_token
          }
        end
    end
    
    def destroy
        destroyed_user = current_user

        if !destroyed_user
          render json: {status: "failed", error: "can't find user to destory session",current_user: destroyed_user}
        end

        destroyed_user.update(session_token: nil)

        render json: {
          status: "complete",
          current_user: @current_user, 
          ad_session_token: nil
        }
    end

    def user_params
        params.permit(:id,:username,:password)
    end

end
