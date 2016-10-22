class FunctionsController < ApplicationController
  layout 'default'

  def index
    @functions = Function.where(private: false).order(created_at: :desc)
  end

  def show
    @function = Function.find(params[:id])
  end
end
