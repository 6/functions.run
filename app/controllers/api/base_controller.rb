class Api::BaseController < ActionController::Base
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

private

  def log_exception(exception)
    Rails.logger.error "#{exception.error_type}: #{exception.message}"
    Rails.logger.error "Backtrace: #{exception.backtrace.join("\n")}"
  end
end
