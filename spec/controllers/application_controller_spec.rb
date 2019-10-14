# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/InstanceVariable
RSpec.describe ApplicationController, type: :controller do
    describe "helper methods" do
        describe "logged_in?" do
            it "returns false if the user isn't logged in" do
                expect(controller.logged_in?).to be false
            end

            it "returns true if the user is logged in" do
                signin_fake_user

                expect(controller.logged_in?).to be true
            end
        end

        describe "current_user" do
            it "is nil if no user is signed in" do
                expect(controller.current_user).to eq(nil)
            end

            it "returns the signed in user" do
                user = signin_fake_user

                expect(controller.current_user).to eq(user)
            end
        end
    end

    describe "signin" do
        it "signs the user in" do
            user = create(:user)
            controller.signin(user)

            expect(@request.session[:user_id]).to eq user.id
        end
    end
end
# rubocop:enable RSpec/InstanceVariable
