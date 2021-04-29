# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/email_verification_mailer
class EmailVerificationMailerPreview < ActionMailer::Preview
    def email_verification
        EmailVerificationMailer.with(user: User.first).email_verification
    end
end
