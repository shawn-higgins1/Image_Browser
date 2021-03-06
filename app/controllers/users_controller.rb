# frozen_string_literal: true

class UsersController < ApplicationController
    before_action :verify_logged_in, only: [:edit, :update]
    before_action :retrieve_user, only: [:update]

    # Display user sign up form
    def new
        # redirect to the root path if the user is already signed in
        redirect_to root_path if current_user

        @user = User.new
    end

    # Create a new user
    def create
        # Create the new user
        @user = User.new(user_params)

        # Attempt to save the new user
        if @user.save
            # Send the email verification email if email is enabled
            redirect_to send_email_verification_path(@user)
        else
            # Display the errors with the account creatation for the user
            flash[:alert] = "<ul>"
            @user.errors.full_messages.each do |msg|
                flash[:alert] += "<li>#{msg}</li>"
            end

            flash[:alert] += "</ul>"

            redirect_to signup_path
        end
    end

    # Display the user profile
    def edit
        @user = current_user
    end

    # Update the user
    def update
        if @user != current_user
            flash[:alert] = I18n.t("users.edit_own_profile")
            return redirect_to root_path
        end

        # Only allow the user to update their username
        if @user.update(user_params.permit(:username))
            flash[:success] = I18n.t("users.success")
        else
            flash[:alert] = I18n.t("users.error") + @user.errors.full_messages.join(', ')
        end

        # Redirect the user to their update profile
        redirect_to edit_users_path
    end

  private

    def user_params
        params.require(:user).permit(:username, :email, :password,
                                    :password_confirmation)
    end
end
