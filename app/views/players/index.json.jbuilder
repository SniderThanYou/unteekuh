json.array!(@players) do |player|
  json.extract! player, :user_id, :name, :color
  json.id player.id.to_s
  json.game_id player.game_id.to_s
  json.url game_player_url(player.game_id.to_s, player.id, format: :json)
end
