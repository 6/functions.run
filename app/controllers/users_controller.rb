class UsersController < ApplicationController
  layout "default"
  before_action :enforce_logged_out!, only: [:new, :create]

  def new
    @user = User.new
  end

  def show
    @user = User.find_by_username_case_insensitive!(params[:username])
    @functions = @user.functions.order(updated_at: :desc)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to user_path(@user.username)
    else
      render :new
    end
  end

private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
