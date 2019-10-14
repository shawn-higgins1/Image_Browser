# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/password_reset_mailer
class ResetPasswordMailerPreview < ActionMailer::Preview
    def password_reset
        ResetPasswordMailer.with(user: User.first).reset_password("http://localhost:3000")
    end
end
