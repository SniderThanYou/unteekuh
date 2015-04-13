class PlayerGateway
  def initialize(game_id)
    @game_id = game_id
  end

  def find_by_id(player_id)
    Game.where(id: @game_id).limit(1).first.players.where(id: player_id).limit(1).first
  end
end