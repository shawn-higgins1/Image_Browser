# frozen_string_literal: true

require 'rails_helper'

def random_valid_user_params
    pass = Faker::Internet.password(min_length: 8)
    {
      user: {
        username: Faker::Internet.user_name,
          email: Faker::Internet.email,
          password: pass,
          password_confirmation: pass
      },
    }
end

RSpec.describe UsersController, type: :controller do
    let(:invalid_params) do
        {
          user: {
            usernname: "Invalid",
              email: "example.com",
              password: "pass",
              password_confirmation: "invalid"
          },
        }
    end

    describe "GET #new" do
        it "display signup" do
            get :new

            expect(response).to render_template :new
            expect(assigns(:user)).to be_a_new(User)
        end

        it "Redirect to root if the user is signed in" do
            signin_fake_user

            get :new

            expect(response).to redirect_to root_path
        end
    end

    describe "POST #create" do
        it "create a valid user and send verification email" do
            params = random_valid_user_params
            post :create, params: params

            user = User.find_by(email: params[:user][:email])

            expect(user).not_to be_nil
            expect(user.username).to eql(params[:user][:username])
            expect(response).to redirect_to send_email_verification_path(user)
        end

        it "notify the user of the valid account creatation" do
            params = invalid_params
            post :create, params: params

            expect(response).to redirect_to signup_path
            expect(flash[:alert]).to eq("<ul><li>Username can't be blank</li><li>Email is invalid</li>"\
                                        "<li>Password is too short (minimum is 6 characters)</li>" \
                                        "<li>Password confirmation doesn't match Password</li></ul>")
        end

        it "signin new user if email is disabled" do
            allow(Rails.configuration).to receive(:email_enabled).and_return(false)

            params = random_valid_user_params
            post :create, params: params

            user = User.find_by(email: params[:user][:email])

            expect(user).not_to be_nil
            expect(user.username).to eql(params[:user][:username])
            # rubocop:disable RSpec/InstanceVariable
            expect(@request.session[:user_id]).to eq(user.id)
            # rubocop:enable RSpec/InstanceVariable
            expect(response).to redirect_to root_path
            expect(flash[:success]).to eq("Welcome to Image Browser")
        end
    end

    describe "GET #edit" do
        it "redirect to root is user isn't signed in" do
            get :edit

            expect(response).to redirect_to root_path
        end

        it "render user profile" do
            user = signin_fake_user

            get :edit

            expect(response).to render_template(:edit)
            expect(assigns(:user)).to eq(user)
        end
    end

    describe "POST #update" do
        it "can't update another user's account" do
            signin_fake_user

            post :update, params: { id: create(:user).id, user: {} }

            expect(response).to redirect_to root_path
            expect(flash[:alert]).to eq("You can only edit your own profile")
        end

        it "can't edit a profile if you aren't signed in" do
            post :update

            expect(response).to redirect_to root_path
        end

        it "updates only the username" do
            user = signin_fake_user

            post :update, params: { id: user.id, user: { username: "shawn", email: "test@example.com" } }

            updated_user = User.find_by(id: user.id)

            expect(response).to redirect_to edit_users_path
            expect(updated_user.email).to eq(user.email)
            expect(updated_user.username).to eq("shawn")
            expect(flash[:success]).to eq("Successfully update your user profile")
        end

        it "fails to update the user" do
            user = signin_fake_user

            post :update, params: { id: user.id, user: { username: nil } }

            updated_user = User.find_by(id: user.id)

            expect(response).to redirect_to edit_users_path
            expect(updated_user.email).to eq(user.email)
            expect(updated_user.username).to eq(user.username)
            expect(flash[:alert]).to eq("Failed to update your user profile: Username can't be blank")
        end
    end
end
