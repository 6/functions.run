class Api::InvocationsController < Api::BaseController
  def create
    @function = Function.find(params[:function_id])
    @function.authorize!(current_user)
    @invocation = @function.invoke!(payload: params[:payload])
    render json: {
      payload: @invocation.payload.string,
      error: @invocation.function_error,
      log_result: @invocation.log_result,
    }
  end
end
