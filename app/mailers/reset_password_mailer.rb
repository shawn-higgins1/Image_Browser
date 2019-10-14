# frozen_string_literal: true

class ResetPasswordMailer < ApplicationMailer
    def reset_password(host)
        @user = params[:user]
        @url = new_password_url(@user.generate_reset_token, @user, host: host)
        mail(to: @user.email, subject: 'Image Browser Password Reset')
    end
end
