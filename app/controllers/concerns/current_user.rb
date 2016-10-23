module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  class Unauthorized < StandardError
  end

  def current_user
    return @current_user if @current_user
    if session[:user_id].present?
      @current_user = User.where(id: session[:user_id]).first
    end
    if header_api_key.present?
      @current_user = User.find_by_api_key(header_api_key)
    end
  end

  def current_user!
    current_user or raise Unauthorized
  end

  def header_api_key
    request.headers['X-API-Key'].presence
  end
end
