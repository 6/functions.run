class LandingPagesController < ApplicationController
  before_action :enforce_logged_out!

  def show
    @featured_functions = Function.featured.where(private: false).order(updated_at: :desc)
  end
end
