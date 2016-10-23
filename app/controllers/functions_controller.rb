class FunctionsController < ApplicationController
  layout 'default'
  before_action :enforce_logged_in!, except: [:index]

  def index
    @functions = Function.where(private: false).order(created_at: :desc)
  end

  def new
    @function = Function.new
  end

  def create
    @function = current_user!.functions.build(create_function_params)
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

  def edit
    @function = current_user!.functions.find(params[:id])
  end

  def update
    @function = current_user!.functions.find(params[:id])
    if @function.update(update_function_params)
      redirect_to user_function_path(current_user!.username, @function.name)
    else
      render :edit
    end
  end

  def destroy
    @function = current_user!.functions.find(params[:id])
    ActiveRecord::Base.transaction do
      @function.delete_remote_function!
      @function.destroy!
    end
    redirect_to user_path(current_user.username)
  end

private

  def create_function_params
    params.require(:function).permit(:name, :description, :private, :code, :runtime, :memory_size, :timeout)
  end

  def update_function_params
    params.require(:function).permit(:name, :description, :private)
  end
end
