# frozen_string_literal: true

class ApplicationController < ActionController::Base
    # Check if there is currently a logged in user
    def logged_in?
        !current_user.nil?
    end
    helper_method :logged_in?

    # Retrieve the current user if there is a user_id saved in the session
    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
    helper_method :current_user

    # Signin the specified user by saving there id in the session
    def signin(user)
        session[:user_id] = user.id
    end

    # If the user isn't logged in redirect them to the
    # home page
    def verify_logged_in
        redirect_to root_path unless logged_in?
    end

    # Retrieve the user specified with the id param and
    # redirect to the home page if that user doesn't exist
    def retrieve_user
        @user = User.find_by(id: params[:id])

        return redirect_to root_path if @user.nil?
    end

    # Redirect to the home page if email isn't enabled
    def verify_email_enabled
        return redirect_to root_path unless Rails.configuration.email_enabled
    end
end
