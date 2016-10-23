class Api::BaseController < ActionController::Base
  include CurrentUser
  include ExceptionHandling

  class ::Exception
    def error_type
      self.class.to_s.underscore.split("/").last
    end

    def as_api_json(options = {})
      {
        error_type: error_type,
        error: message,
      }
    end
  end

  class ActiveRecord::RecordInvalid < ActiveRecord::ActiveRecordError
    def as_api_json(options = {})
      super.merge(errors: record.errors)
    end
  end

  rescue_from Unauthorized do |e|
    log_exception(e)
    render json: e.as_api_json, status: 403
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    log_exception(e)
    render json: e.as_api_json, status: 404
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    log_exception(e)
    render json: e.as_api_json, status: 422
  end

  rescue_from Aws::Lambda::Errors::ServiceError, Aws::Errors::ServiceError, RuntimeError do |e|
    log_exception(e)
    Rollbar.error(e)
    render json: e.as_api_json, status: 500
  end
end
