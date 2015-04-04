json.array!(@games) do |game|
  json.extract! game, :name
  json.id game.id.to_s
  json.url game_url(game, format: :json)
end
