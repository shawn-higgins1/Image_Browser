class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      signin(user)
      redirect_to root_path
    else
      flash[:alert] = "Invalid email or password"
      redirect_to signin_path
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
