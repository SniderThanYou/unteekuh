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

  def randomize_player_order
    game = self.find_by_id
    game.player_order = game.players.collect{|p| p.id}.shuffle
    game.save
  end

  def start_playing
    find_by_id.start_playing
  end

  def current_player?(player_id)
    find_by_id.player_order.first == player_id
  end

  def moving_on_rondel?
    find_by_id.moving_on_rondel?
  end

  def founding_cities?
    find_by_id.founding_cities?
  end

  def ready_to_found_cities
    find_by_id.ready_to_found_cities
  end

  def ready_to_collect_great_people
    find_by_id.ready_to_collect_great_people
  end

  # def next_turn
  #   game = self.find_by_id
  #   game.player_order.rotate!
  #   game.save
  # end
end