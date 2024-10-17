class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token

    helper_method :current_user, :current_user_username, :logged_in?, :login_user!

    def current_user
        ad_session_token = request.headers['HTTP_AD_SESSION_TOKEN']
        return nil unless ad_session_token 
        @current_user = User.find_by(session_token: ad_session_token)
        # Old method below with session_token is not appropriate due to separate client sessionStorage
        #@current_user ||= User.find_by(session_token: session[:session_token])
    end
    
    def current_user_username
      @current_user ? @current_user.username : nil
    end
  
    def logged_in?
      !!current_user
    end
  
    def login_user!(user)
      #session[:session_token] = user.reset_session_token!
      @session_token = user.reset_session_token!
    end
    
    #   def require_user!
    #     redirect_to new_session_url if current_user.nil?
    #   end
end
