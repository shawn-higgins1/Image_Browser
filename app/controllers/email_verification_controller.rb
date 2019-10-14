# frozen_string_literal: true

class EmailVerificationController < ApplicationController
    before_action :verify_email_enabled
    before_action :retrieve_user

    # Send an email verification email
    def send_email
        # If the user has already verified there email redirect to the homepage
        return redirect_to root_path if @user.email_verified

        # Send the email
        EmailVerificationMailer.with(user: @user)
                               .email_verification(request.host || Rails.configuration.default_host)

        # Notify the user that the email has been sent and redirect to the homepage
        flash[:success] = "We've sent your account activation email." \
                            " Check your email and follow the instructions to activate your account."

        redirect_to root_path
    end

    # Process the email verification
    def verify_account
        # Retrieve the token and verify that it is a valid token
        token = params[:token]

        if token.nil?
            flash[:alert] = "Invalid attempt to authenticate your account."
            return redirect_to root_path
        end

        # Verfiy that the specified token matches the specified users token
        if !@user.verify_token("email_verification", token)
            flash[:alert] = "Invalid attempt to authenticate your account."
        else
            # Update that the users email has been verified
            @user.email_verification_token = nil
            @user.email_verified = true

            # Save the user account and signin the user
            if @user.save!
                signin(@user)
                flash[:success] = "Welcome to Image Browser"
            else
                flash[:alert] = "Something went wrong when updating the account"
            end
        end

        redirect_to root_path
    end
end
