# frozen_string_literal: true

class ApplicationController < ActionController::Base
    def logged_in?
        !current_user.nil?
    end
    helper_method :logged_in?

    def verify_logged_in
        redirect_to root_path unless logged_in?
    end

    def signin(user)
        session[:user_id] = user.id
    end
    helper_method :sign_in

    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
end
