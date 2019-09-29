# frozen_string_literal: true

class User < ApplicationRecord
    before_save { email.try(:downcase!) }
    
    validates :username, presence: true, length: { maximum: 256 }, uniqueness: true
    validates :email, presence: true, length: { maximum: 256 },
                        format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                        uniqueness: { case_sensitive: false }

    validates :password, length: { minimum: 6 }

    has_secure_password
end
