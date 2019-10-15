# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResetPasswordController, type: :controller do
    describe "require email enabled" do
        before do
            allow(Rails.configuration).to receive(:email_enabled).and_return(false)
        end

        it "don't send if email is disabled" do
            expect { post :send_email, params: { id: 1 } }.to change { ActionMailer::Base.deliveries.count }.by(0)
            expect(response).to redirect_to root_path
        end

        it "don't show forgot password form" do
            get :forgot_password

            expect(response).to redirect_to root_path
        end

        it "don't show new password entry" do
            get :edit_password, params: { id: 1, token: 1 }

            expect(response).to redirect_to root_path
        end

        it "don't verify if email is disabled" do
            post :reset_password, params: { id: 1, token: 1 }

            expect(response).to redirect_to root_path
        end
    end

    it "redirects for invalid id" do
        post :reset_password, params: { id: 1, token: 1 }

        expect(response).to redirect_to root_path
    end

    describe "GET #forgot_password" do
        it "render forgot password form" do
            get :forgot_password

            expect(response).to render_template(:forgot_password)
        end
    end

    describe "POST #send_email" do
        it "send verification email" do
            user = create(:user)

            expect { post :send_email, params: { email: user.email } }.to change { ActionMailer::Base.deliveries.count }
              .by(1)

            expect(response).to redirect_to root_path
            expect(flash[:success]).to eq(I18n.t("reset_password.sent_email"))
        end
    end

    describe "GET #edit_password" do
        it "render new password template" do
            user = create(:user)

            get :edit_password, params: { id: user.id, token: 1 }

            expect(response).to render_template(:edit_password)
        end
    end

    describe "GET #verify_account" do
        it "dont' update the password for and invalid token" do
            user = create(:user)
            user.generate_password_reset_token

            post :reset_password, params: { id: user.id, token: "" }

            expect(response).to redirect_to root_path
            expect(flash[:alert]).to eq(I18n.t("reset_password.failed"))
        end

        it "update user's password with valid token" do
            user = create(:user, password: "qwerty12", password_confirmation: "qwerty12")

            post :reset_password, params: { id: user.id, token: user.generate_password_reset_token,
                                            user: { password: "1234567", password_confirmation: "1234567" } }

            updated_user = User.find_by(id: user.id)

            expect(response).to redirect_to signin_path
            expect(updated_user&.authenticate("1234567")).to eq(updated_user)
            expect(updated_user&.authenticate("qwerty12")).to be false
            expect(flash[:success]).to eq(I18n.t("reset_password.success"))
        end

        it "notify user if update fails" do
            user = create(:user, password: "qwerty12", password_confirmation: "qwerty12")
            token = user.generate_password_reset_token
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(User).to receive(:update).and_return(false)
            # rubocop:enable RSpec/AnyInstance

            post :reset_password, params: { id: user.id, token: token,
                                            user: { password: "1234567", password_confirmation: "1234567" } }

            updated_user = User.find_by(id: user.id)

            expect(response).to redirect_to root_path
            expect(updated_user&.authenticate("1234567")).to be false
            expect(updated_user&.authenticate("qwerty12")).to eq(updated_user)
            expect(flash[:alert]).to eq(I18n.t("reset_password.failed"))
        end
    end
end
