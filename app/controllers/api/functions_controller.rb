class Api::FunctionsController < Api::BaseController
  def show
    @function = Function.find(params[:id])
    render json: @function
  end

  def create
    ActiveRecord::Base.transaction do
      @function = Function.create!(create_function_params)
      @function.create_remote_function!
    end
    render json: @function
  end

  def update
    @function = Function.find(params[:id])
    ActiveRecord::Base.transaction do
      @function.update!(update_local_function_params) if update_local_function_params.present?
      @function.update_code!(params[:code]) if params[:code].present?
      if update_remote_configuration_params.present?
        @function.update_remote_configuration!(
          timeout: update_remote_configuration_params[:timeout],
          memory_size: update_remote_configuration_params[:memory_size],
          runtime: update_remote_configuration_params[:runtime],
        )
      end
    end
    render json: @function
  end

  def destroy
    @function = Function.find(params[:id])
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

  def update_remote_configuration_params
    params.permit(:runtime, :memory_size, :timeout)
  end
end
