# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
    let(:user) { create(:user) }

    describe 'validations' do
        it { is_expected.to validate_presence_of(:username) }
        it { is_expected.to validate_length_of(:username).is_at_most(256) }
        it { is_expected.to validate_uniqueness_of(:username) }

        it { is_expected.to validate_presence_of(:email) }
        it { is_expected.to validate_length_of(:email).is_at_most(256) }
        it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

        it { is_expected.to allow_value("valid@email.com").for(:email) }
        it { is_expected.not_to allow_value("invalid_email").for(:email) }

        it { is_expected.to validate_length_of(:password).is_at_least(6) }

        it "converts email to downcase on save" do
          user = create(:user, email: "DOWNCASE@DOWNCASE.COM")
          expect(user.email).to eq("downcase@downcase.com")
        end
    end

    describe 'generate tokens' do
        it "generate password reset token" do
            token = user.generate_password_reset_token

            expect(BCrypt::Password.new(user.reset_password_token).is_password?(token)).to be true
            expect(user.reset_password_sent_at).to be_within(5.seconds).of(Time.now.utc)
        end

        it "generate email authentication token" do
            token = user.generate_email_authentication_token

            expect(BCrypt::Password.new(user.email_verification_token).is_password?(token)).to be true
        end
    end

    describe 'verify tokens' do
        it "return false if user hasn't requested a token" do
            expect(user.verify_token("email_verification", "")).to be false
        end

        it "return false for invalid token" do
            user.generate_email_authentication_token

            expect(user.verify_token("email_verification", "asdasd")).to be false
        end

        it "return true for valid email token" do
            token = user.generate_email_authentication_token

            expect(user.verify_token("email_verification", token)).to be true
        end

        it "return true for valid password token" do
            token = user.generate_password_reset_token

            expect(user.verify_token("reset_password", token)).to be true
        end

        it "return false if the password token has expired" do
            token = user.generate_password_reset_token
            user.update(reset_password_sent_at: Time.now.utc - 5.hours)

            expect(user.verify_token("reset_password", token)).to be false
        end
    end
end
