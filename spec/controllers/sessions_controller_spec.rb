# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
    describe "GET #new" do
        it "displays signin" do
            get :new

            expect(response).to render_template(:new)
        end

        it "can't signin if your already logged in" do
            signin_fake_user

            get :new

            expect(response).to redirect_to root_path
        end
    end

    describe "POST #create" do
        it "reject if the email is invalid" do
            post :create, params: { session: { email: "test@example.com" } }

            expect(response).to redirect_to signin_path
            expect(flash[:alert]).to eq(I18n.t("sessions.error"))
        end

        it "reject if the password is invalid" do
            user = create(:user)
            post :create, params: { session: { email: user.email, password: "" } }

            expect(response).to redirect_to signin_path
            expect(flash[:alert]).to eq(I18n.t("sessions.error"))
        end

        it "notify the user if they haven't verified their email" do
            user = create(:user, password: "1234567", password_confirmation: "1234567")

            post :create, params: { session: { email: user.email, password: "1234567" } }

            expect(response).to redirect_to root_path
            expect(flash[:info]).to eq(I18n.t("sessions.email_verification_required",
                                                link: send_email_verification_path(user)))
        end

        it "signin the user" do
            user = create(:user, email_verified: true, password: "1234567", password_confirmation: "1234567")

            post :create, params: { session: { email: user.email, password: "1234567" } }

            expect(response).to redirect_to root_path
            # rubocop:disable RSpec/InstanceVariable
            expect(@request.session[:user_id]).to eq(user.id)
          # rubocop:enable RSpec/InstanceVariable
        end
    end

    describe "DELETE #destroy" do
        # rubocop:disable RSpec/InstanceVariable
        it "logouts the user" do
            signin_fake_user
            delete :destroy

            expect(@request.session[:user_id]).to be_nil
            expect(response).to redirect_to root_path
        end

        it "nothing shoul happen if no user is signed in" do
            delete :destroy

            expect(@request.session[:user_id]).to be_nil
            expect(response).to redirect_to root_path
        end
      # rubocop:enable RSpec/InstanceVariable
    end
end
