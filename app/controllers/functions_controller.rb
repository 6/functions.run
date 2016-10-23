class FunctionsController < ApplicationController
  layout 'default'
  before_action :enforce_logged_in!, only: [:new, :create]

  def index
    @functions = Function.where(private: false).order(created_at: :desc)
  end

  def new
    @function = Function.new
  end

  def create
    @function = current_user!.functions.build(create_user_function_params)
    if @function.valid?
      ActiveRecord::Base.transaction do
        @function.save!
        @function.create_remote_function!
      end
      redirect_to user_function_path(current_user!.username, @function.name)
    else
      render :new
    end
  end

private

  def create_user_function_params
    params.require(:function).permit(:name, :description, :private, :code, :runtime, :memory_size, :timeout)
  end
end
