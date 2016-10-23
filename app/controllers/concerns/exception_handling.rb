module ExceptionHandling
  extend ActiveSupport::Concern

  def log_exception(exception)
    return if Rails.env.test?
    Rails.logger.error "#{exception.error_type}: #{exception.message}"
    Rails.logger.error "Backtrace: #{exception.backtrace.join("\n")}"
  end
end
