# frozen_string_literal: true

class SessionsController < ApplicationController
    # Display the login form
    def new
        # Redirect to the root if the user is already signed in
        redirect_to root_path if current_user
    end

    # Login / create a new user session
    def create
        # Find the user
        user = User.find_by(email: params[:session][:email].downcase)

        # Create that the password they gave is correct
        if user&.authenticate(params[:session][:password])
            # If email is enabled but the user hasn't verified their email address
            # don't log the user in instead just notify them that they need to
            # verify their account
            if Rails.configuration.email_enabled && !user.email_verified
                flash[:info] = "You must verify your email address before you can access ImageBrowser." \
                                " Please check your email for the verification email or click" \
                                " <a href=\"#{send_email_verification_path(user)}\">here</a>" \
                                " to resend the email."
                return redirect_to root_path
            end

            # Sign in the user
            signin(user)
            redirect_to root_path
        else
            # Notify the user that the login failed but don't tell them why
            flash[:alert] = "Invalid email or password"
            redirect_to signin_path
        end
    end

    # Sign out the user and redirect the to the home page
    def destroy
        session.delete(:user_id)
        @current_user = nil

        redirect_to root_path
    end
end
