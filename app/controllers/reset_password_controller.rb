# frozen_string_literal: true

class ResetPasswordController < ApplicationController
    before_action :verify_email_enabled
    before_action :verify_user, except: [:forgot_password]

    def forgot_password
    end

    def send_email
        ResetPasswordMailer.with(user: @user)
                           .reset_password(request.host || Rails.configuration.default_host)

        flash[:success] = "We've sent your password reset email." \
                            " Check your email and follow the instructions to reset your account."

        redirect_to root_path
    end

    def edit_password
        @token = params[:token]
    end

    def reset_password
        token = params[:token]

        if token.nil?
            flash[:alert] = "Invalid attempt to reset your password."
            return redirect_to root_path
        end

        if @user.verify_token("reset_password", token) &&
           @user.update(params.require(:user).permit(:password, :password_confirmation))
                flash[:success] = "Succesfully reset your password"
                redirect_to signin_path
        else
            flash[:alert] = "Invalid attempt to reset your password."
            redirect_to root_path
        end
    end

  private

    def verify_user
        @user = User.find_by(id: params[:id]) || User.find_by(email: params[:email])

        if @user.nil?
            flash[:alert] = "Couldn't send the password reset email. The supplied user was invalid."
            return redirect_to root_path
        end
    end

    def verify_email_enabled
        return redirect_to root_path unless Rails.configuration.email_enabled
    end
end
