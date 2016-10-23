class ApplicationController < ActionController::Base
  include CurrentUser
  include ExceptionHandling

  protect_from_forgery with: :exception

  def enforce_logged_out!
    redirect_to user_path(current_user.username) if current_user
  end

  def enforce_logged_in!
    redirect_to new_session_path unless current_user
  end

  rescue_from Unauthorized do |e|
    redirect_to new_session_path
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    log_exception(e)
    render file: "public/404.html", status: 404, layout: nil
  end
end
