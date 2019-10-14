# frozen_string_literal: true

class EmailVerificationMailer < ApplicationMailer
    # Send the email verification email
    def email_verification(host)
        @user = params[:user]
        @url = verify_email_url(@user.generate_email_authentication_token, @user, host: host)
        mail(to: @user.email, subject: 'Image Browser Email Verification')
    end
end
