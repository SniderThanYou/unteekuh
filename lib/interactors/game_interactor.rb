class GameInteractor
  def initialize(game_id)
    @game_id = game_id
    @game_gateway = GameGateway.new(@game_id)
    @board_gateway = BoardGateway.new(@game_id)
  end

  def add_player(user)
    raise 'Players can only be added during the player signup phase' unless @game_gateway.in_player_signup?
    raise 'You are already in this game' if PlayerGateway.find_player_in_game(@game_id, user.id)
    @game_gateway.add_player(user)
  end

  def start_game
    @game_gateway.set_board(BoardGateway.create_orient)
    @game_gateway.start_playing
  end

  def found_city(player_id, city_name)
    raise 'city already owned' if @board_gateway.owner_of(city_name)
    PlayerGateway.subtract_resources_from_player(player_id, {gold: 1, marble: 1, iron: 1})
    @board_gateway.found_city(city_name, player_id)
  end

  def purchase_tech(player_id, tech_name)
    raise 'you already own that tech' if @board_gateway.player_has_tech?(player_id, tech_name)
    g = @board_gateway.gold_cost_of_tech(tech_name)
    PlayerGateway.subtract_resources_from_player(player_id, {gold: g})
  end
end