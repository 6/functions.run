Rails.application.routes.draw do
  namespace :api do
    resources :functions, only: [:show, :create, :update, :destroy] do
      resources :invocations, only: [:create]
    end
  end

  root to: "landing_pages#show"
end
