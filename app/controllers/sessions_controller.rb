# frozen_string_literal: true

class SessionsController < ApplicationController
    def new
        redirect_to root_path if current_user
    end

    def create
        user = User.find_by(email: params[:session][:email].downcase)
        if user&.authenticate(params[:session][:password])
            if Rails.configuration.email_enabled && !user.email_verified
                flash[:alert] = "You must verify your email address before you can access ImageBrowser." \
                                " Please check your email for the verification email or click" \
                                " <a href=\"#{send_email_verification_path(user)}\">here</a>" \
                                " to resend the email."
                return redirect_to root_path
            end

            signin(user)
            redirect_to root_path
        else
            flash[:alert] = "Invalid email or password"
            redirect_to signin_path
        end
    end

    def destroy
        sign_out
        redirect_to root_path
    end

  private

    def sign_out
        session.delete(:user_id)
        @current_user = nil
    end
end
