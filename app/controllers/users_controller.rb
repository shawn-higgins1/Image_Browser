# frozen_string_literal: true

class UsersController < ApplicationController
  def new
    redirect_to root_path if current_user

    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # avatar = params[:user][:avatar]
    # unless avatar.nil?
    #   if valid_image?(avatar)
    #     @user.avatar.attach(avatar)
    #   else
    #     flash[:alert] = "The file you provided was not a valid image file"
    #     redirect_to signup_path
    #   end
    # end

    if @user.save
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

  private

  def user_params
    params.require(:user).permit(:username, :email, :password,
                                 :password_confirmation)
  end
end
