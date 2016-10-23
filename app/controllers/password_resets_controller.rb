class PasswordResetsController < ApplicationController
  before_action :enforce_logged_out!

  def new
  end
end
