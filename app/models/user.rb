# frozen_string_literal: true

class User < ApplicationRecord
    has_many :photos, dependent: :destroy

    before_save { email.try(:downcase!) }

    validates :username, presence: true, length: { maximum: 256 }, uniqueness: true
    validates :email, presence: true, length: { maximum: 256 },
                      format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                      uniqueness: { case_sensitive: false }

    validates :password, length: { minimum: 6 }, if: :password_update

    has_secure_password

    # Create a password reset token
    def generate_password_reset_token
        token = generate_token
        update(reset_password_token: BCrypt::Password.create(token))
        update(reset_password_sent_at: Time.now.utc)
        token
    end

    # Create an email authentication token
    def generate_email_authentication_token
        token = generate_token
        update(email_verification_token: BCrypt::Password.create(token))
        token
    end

    # Verify that the specified token is valid
    def verify_token(attribute, token)
        # Retrieve the hashed token
        digest = send("#{attribute}_token")
        return false if digest.nil?

        # If the token is a password reset token check that the time period is still valid
        return false if attribute == "reset_password" && (reset_password_sent_at + 4.hours) < Time.now.utc

        # Test that the token matches the stored token hash
        BCrypt::Password.new(digest).is_password?(token)
    end

  private

    # Generate a random token
    def generate_token
        SecureRandom.hex(10)
    end

    # Determine whether or not the password is being updated
    def password_update
        !password_confirmation.nil? || !password.nil?
    end
end
