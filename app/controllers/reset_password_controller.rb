# frozen_string_literal: true

class ResetPasswordController < ApplicationController
    before_action :verify_email_enabled
    before_action :verify_user, except: [:forgot_password]

    # Render form where user can enter email address for retrieval
    def forgot_password
    end

    # Send the password reset email
    def send_email
        # Send the email
        ResetPasswordMailer.with(user: @user)
                           .reset_password(request.host || Rails.configuration.default_host).deliver_later

        # Notify the user that the email was sent
        flash[:success] = "We've sent your password reset email." \
                            " Check your email and follow the instructions to reset your password."

        redirect_to root_path
    end

    # Display the form where the user can enter their new password
    def edit_password
        @token = params[:token]
    end

    # Reset the users password if the token is valid
    def reset_password
        token = params[:token]

        # If the token is valid update the users password
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

    # Verify that the supplied user existing either from the id param of the email param
    def verify_user
        @user = User.find_by(id: params[:id]) || User.find_by(email: params[:email])

        if @user.nil?
            flash[:alert] = "Couldn't send the password reset email. The supplied user was invalid."
            return redirect_to root_path
        end
    end
end
