class Api::FunctionsController < Api::BaseController
  def show
    @function = Function.find(params[:id])
    @function.authorize!(current_user)
    render json: @function
  end

  def create
    ActiveRecord::Base.transaction do
      @function = current_user!.functions.create!(create_function_params)
      @function.create_remote_function!
    end
    render json: @function
  end

  def update
    @function = current_user!.functions.find(params[:id])
    ActiveRecord::Base.transaction do
      @function.update!(update_local_function_params) if update_local_function_params.present?
      @function.update_remote_function!(update_remote_function_params) if update_remote_function_params.present?
    end
    render json: @function
  end

  def destroy
    @function = current_user!.functions.find(params[:id])
    ActiveRecord::Base.transaction do
      @function.delete_remote_function!
      @function.destroy!
    end
    render json: {success: true}
  end

private

  def create_function_params
    params.permit(:name, :description, :private, :code, :runtime, :memory_size, :timeout)
  end

  def update_local_function_params
    params.permit(:name, :description, :private)
  end

  def update_remote_function_params
    params.permit(:code, :runtime, :memory_size, :timeout)
  end
end
