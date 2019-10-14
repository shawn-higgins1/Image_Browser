# frozen_string_literal: true

class UsersController < ApplicationController
    before_action :verify_logged_in, only: [:edit, :update]
    def new
        redirect_to root_path if current_user

        @user = User.new
    end

    def create
        @user = User.new(user_params)

        if @user.save
            return redirect_to send_email_verification_path(@user) if Rails.configuration.email_enabled

            signin(@user)
            flash[:success] = "Welcome to Image Browser"
            redirect_to root_path
        else
            flash[:alert] = "<ul>"
            @user.errors.full_messages.each do |msg|
                flash[:alert] += "<li>" + msg + "</li>"
            end

            flash[:alert] += "</ul>"

            redirect_to signup_path
        end
    end

    def edit
        @user = current_user
    end

    def update
        user = User.find_by(id: params[:id])

        if user.nil? || user != current_user
            flash[:alert] = "You can only edit your own profile"
            return redirect_to root_path
        end

        if user.update(user_params.permit(:username))
            flash[:success] = "Successfully update your user profile"
        else
            flash[:alert] = "Failed to update your user profile"
        end

        redirect_to edit_users_path(user)
    end

  private

    def user_params
        params.require(:user).permit(:username, :email, :password,
                                    :password_confirmation)
    end
end
