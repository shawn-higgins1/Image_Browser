# frozen_string_literal: true

class User < ApplicationRecord
    has_many :photos, dependent: :destroy

    before_save { email.try(:downcase!) }

    validates :username, presence: true, length: { maximum: 256 }, uniqueness: true
    validates :email, presence: true, length: { maximum: 256 },
                        format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                        uniqueness: { case_sensitive: false }

    validates :password, length: { minimum: 6 }, on: :create

    has_secure_password

    def generate_reset_token
        token = generate_token
        update(reset_password_token: BCrypt::Password.create(token))
        update(reset_password_sent_at: Time.now.utc)
        token
    end

    def generate_email_authentication_token
        token = generate_token
        update(email_verification_token: BCrypt::Password.create(token))
        token
    end

    def verify_token(attribute, token)
        digest = send("#{attribute}_token")
        return false if digest.nil?

        return false if attribute == "reset_password" && (reset_password_sent_at + 4.hours) < Time.now.utc

        BCrypt::Password.new(digest).is_password?(token)
    end

  private

    def generate_token
        SecureRandom.hex(10)
    end
end
