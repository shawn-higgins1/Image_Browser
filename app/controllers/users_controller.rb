# frozen_string_literal: true

class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def update
  end

  def create  
    @user = User.new(user_params)
    if @user.save
      signin(@user)
      flash[:success] = "Welcome to the Image Browser"
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
