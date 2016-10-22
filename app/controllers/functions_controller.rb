class FunctionsController < ApplicationController
  def index
    @functions = Function.order(created_at: :desc)
  end

  def show
  end
end
