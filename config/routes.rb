Rails.application.routes.draw do
  devise_for :users
  root to: "games#index"
  resources :games do
    post '/start_game', action: :start_game, on: :member, as: :start
    resources :players do
      post '/move_on_rondel/:rondel_loc', action: :move_on_rondel, on: :member, as: :move_on_rondel
    end
  end
end
