class GameGateway
  def initialize(game_id)
    @game_id = game_id
  end

  def find_by_id
    Game.where(id: @game_id).limit(1).first
  end

  def in_player_signup?
    self.find_by_id.player_signup?
  end

  def add_player(user)
    game = self.find_by_id
    game.players.create(user_id: user.id, name: user.email)
  end

  def set_board(board)
    game = self.find_by_id
    game.board = board
    game.save
  end

  def start_playing
    find_by_id.start_playing
  end
end