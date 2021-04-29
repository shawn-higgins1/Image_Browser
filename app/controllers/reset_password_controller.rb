# frozen_string_literal: true

class ResetPasswordController < ApplicationController
    before_action :verify_user, except: [:forgot_password]

    # Render form where user can enter email address for retrieval
    def forgot_password
    end

    # Send the password reset email
    def send_email
        # Send the email
        ResetPasswordMailer.with(user: @user)
                           .reset_password.deliver_later

        # Notify the user that the email was sent
        flash[:success] = I18n.t("reset_password.sent_email")

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
                flash[:success] = I18n.t("reset_password.success")
                redirect_to signin_path
        else
            flash[:alert] = I18n.t("reset_password.failed")
            redirect_to root_path
        end
    end

  private

    # Verify that the supplied user existing either from the id param of the email param
    def verify_user
        @user = User.find_by(id: params[:id]) || User.find_by(email: params[:email])

        return redirect_to root_path if @user.nil?
    end
end
