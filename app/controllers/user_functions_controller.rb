class UserFunctionsController < ApplicationController  
  def show
    @user = User.find_by_username_case_insensitive!(params[:username])
    @function = @user.functions.find_by_name!(params[:function_name])
    @function.authorize!(current_user)
  end
end
