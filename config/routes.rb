Rails.application.routes.draw do
  namespace :api do
    resources :functions, only: [:show, :create, :update, :destroy] do
      resources :invocations, only: [:create]
    end
  end

  resources :functions, only: [:index, :new, :create]

  get '/signup' => 'users#new', as: :new_user
  post '/signup' => 'users#create', as: :create_user

  get '/login' => 'sessions#new', as: :new_session
  post '/login' => 'sessions#create', as: :create_session
  get '/logout' => 'sessions#destroy', as: :destroy_session

  get '/:username', to: 'users#show', as: :user
  get '/:username/:function_name', to: 'user_functions#show', as: :user_function

  root to: "landing_pages#show"
end
