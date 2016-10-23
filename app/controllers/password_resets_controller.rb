class PasswordResetsController < ApplicationController
  layout "default"
  before_action :enforce_logged_out!
  
  def new
  end
end
