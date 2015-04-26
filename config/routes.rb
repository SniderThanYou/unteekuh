Rails.application.routes.draw do
  devise_for :users
  root to: "games#index"
  resources :games do
    post '/start_game', action: :start_game, on: :member, as: :start
    resources :players do
      post '/move_on_rondel/:rondel_loc', action: :move_on_rondel, on: :member, as: :move_on_rondel
      post '/build_temple/:city', action: :build_temple, on: :member, as: :build_temple
      post '/done_building_temples', action: :done_building_temples, on: :member, as: :done_building_temples
      post '/arm_footman/:city', action: :arm_footman, on: :member, as: :arm_footman
      post '/arm_boat/:city', action: :arm_boat, on: :member, as: :arm_boat
      post '/done_arming', action: :done_arming, on: :member, as: :done_arming
      post '/research_tech/:tech', action: :research_tech, on: :member, as: :research_tech
      post '/done_researching_techs', action: :done_researching_techs, on: :member, as: :done_researching_techs
      post '/done_founding_cities', action: :done_founding_cities, on: :member, as: :done_founding_cities
    end
  end
end
