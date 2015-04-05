json.array!(@games) do |game|
  json.extract! game, :name, :state
  json.id game.id.to_s
  json.url game_url(game, format: :json)
end
