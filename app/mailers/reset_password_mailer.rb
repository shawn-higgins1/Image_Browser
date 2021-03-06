# frozen_string_literal: true

class ResetPasswordMailer < ApplicationMailer
    # Send the reset password email
    def reset_password
        @user = params[:user]
        @url = new_password_url(@user.generate_password_reset_token, @user)
        mail(to: @user.email, subject: I18n.t("reset_password.subject"))
    end
end
