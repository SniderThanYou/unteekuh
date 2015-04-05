Rails.application.routes.draw do
  devise_for :users
  root to: "games#index"
  resources :games do
    post '/start_game', to: :start_game, on: :member, as: :start
    resources :players
  end
end
