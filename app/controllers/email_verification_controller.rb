# frozen_string_literal: true

class EmailVerificationController < ApplicationController
    before_action :verify_email_enabled

    def send_email
        user = User.find_by(id: params[:id])

        if user.nil?
            flash[:alert] = "Couldn't send the account activation email. The supplied user was invalid."
            return redirect_to root_path
        end

        return redirect_to root_path if user.email_verified

        EmailVerificationMailer.with(user: user)
                               .email_verification(request.host || Rails.configuration.default_host)

        flash[:success] = "We've sent your account activation email." \
                            " Check your email and follow the instructions to active your account."

        redirect_to root_path
    end

    def verify_account
        token = params[:token]

        if token.nil?
            flash[:alert] = "Invalid attempt to authenticate your account."
            return redirect_to root_path
        end

        user = User.find_by(id: params[:id])

        if user.nil? || !user.verify_token("email_verification", token)
            flash[:alert] = "Invalid attempt to authenticate your account."
        else
            user.email_verification_token = nil
            user.email_verified = true

            if user.save!
                signin(user)
                flash[:success] = "Welcome to Image Browser"
            else
                flash[:alert] = "Something went wrong when updating the account"
            end
        end

        redirect_to root_path
    end

  private

    def verify_email_enabled
        return redirect_to root_path unless Rails.configuration.email_enabled
    end
end
