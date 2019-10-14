# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailVerificationController, type: :controller do
    describe "require email enabled" do
        before do
            allow(Rails.configuration).to receive(:email_enabled).and_return(false)
        end

        it "don't send if email is disabled" do
            expect { get :send_email, params: { id: 1 } }.to change { ActionMailer::Base.deliveries.count }.by(0)
            expect(response).to redirect_to root_path
        end

        it "don't verify if email is disabled" do
            get :verify_account, params: { id: 1, token: 1 }

            expect(response).to redirect_to root_path
        end
    end

    describe "GET #send_email" do
        it "don't send email if user is already verified" do
            user = create(:user, email_verified: true)

            expect { get :send_email, params: { id: user.id } }.to change { ActionMailer::Base.deliveries.count }.by(0)
            expect(response).to redirect_to root_path
        end

        it "send verification email" do
            user = create(:user)

            expect { get :send_email, params: { id: user.id } }.to change { ActionMailer::Base.deliveries.count }.by(1)
            expect(response).to redirect_to root_path
            expect(flash[:success]).to eq("We've sent your account activation email." \
                                            " Check your email and follow the instructions to activate your account.")
        end
    end

    describe "GET #verify_account" do
        it "dont' verify for invalid token" do
            user = create(:user)
            user.generate_email_authentication_token

            get :verify_account, params: { id: user.id, token: "" }

            expect(response).to redirect_to root_path
            expect(flash[:alert]).to eq("Invalid attempt to authenticate your account.")
        end

        it "update user with valid token" do
            user = create(:user)

            get :verify_account, params: { id: user.id, token: user.generate_email_authentication_token }

            updated_user = User.find_by(id: user.id)

            expect(response).to redirect_to root_path
            expect(updated_user.email_verified).to be true
            expect(updated_user.email_verification_token).to be_nil
            expect(flash[:success]).to eq("Welcome to Image Browser")
        end

        it "notify user if save fails" do
            user = create(:user)
            token = user.generate_email_authentication_token
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(User).to receive(:save!).and_return(false)
            # rubocop:enable RSpec/AnyInstance

            get :verify_account, params: { id: user.id, token: token }

            updated_user = User.find_by(id: user.id)

            expect(response).to redirect_to root_path
            expect(updated_user.email_verified).to be false
            expect(updated_user.email_verification_token).not_to be_nil
            expect(flash[:alert]).to eq("Something went wrong when updating the account")
        end
    end
end
