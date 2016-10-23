class SessionsController < ApplicationController
  before_action :enforce_logged_out!, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by_email(params[:email_or_username])
    user ||= User.find_by_username_case_insensitive(params[:email_or_username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to user_path(user.username)
    else
      @invalid = true
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
