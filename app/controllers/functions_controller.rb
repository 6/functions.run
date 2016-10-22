class FunctionsController < ApplicationController
  layout 'default'

  def index
    @functions = Function.where(private: false).order(created_at: :desc)
  end

  def show
  end
end
