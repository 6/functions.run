class UsersController < ApplicationController
  before_action :enforce_logged_out!, only: [:new, :create]

  def new
    @user = User.new
  end

  def show
    @user = User.find_by_username_case_insensitive!(params[:username])
    if @user.id == current_user&.id
      @is_self = true
      @functions = @user.functions
    else
      @is_self = false
      @functions = @user.functions.where(private: false)
    end
    @functions = @functions.order(updated_at: :desc)
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
