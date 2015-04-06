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
    players = @game_gateway.player_ids
    @game_gateway.randomize_player_order
    @game_gateway.set_board(BoardGateway.create_orient(players))
    @game_gateway.start_playing
  end

  def move_on_rondel(new_spot, movement_cost)

  end

  def collect_gold(player_id)
    verify_player_turn(player_id)
    verify_moving_on_rondel
    #move_on_rondel(move_payment)
    g = @board_gateway.gold_produced_by(player_id)
    PlayerGateway.add_resources_to_player(player_id, {gold: g})
    ready_to_found_cities
  end

  def collect_marble(player_id)
    verify_player_turn(player_id)
    verify_moving_on_rondel
    #move_on_rondel(move_payment)
    m = @board_gateway.marble_produced_by(player_id)
    PlayerGateway.add_resources_to_player(player_id, {marble: m})
    ready_to_found_cities
  end

  def collect_iron(player_id)
    verify_player_turn(player_id)
    verify_moving_on_rondel
    #move_on_rondel(move_payment)
    i = @board_gateway.iron_produced_by(player_id)
    PlayerGateway.add_resources_to_player(player_id, {iron: i})
    ready_to_found_cities
  end

  def purchase_tech(player_id, tech_names)
    verify_player_turn(player_id)
    verify_moving_on_rondel
    tech_names.each do |tech_name|
      raise "you already own #{tech_name}" if @game_gateway.player_has_tech?(player_id, tech_name)
      raise "you do not own the prerequisite tech for #{tech_name}" unless @game_gateway.player_has_prerequisite_for_tech?(player_id, tech_name) || prerequisite_included(tech_names, tech_name)
      g = @game_gateway.gold_cost_of_tech(tech_name)
    end
    #move_on_rondel(move_payment + cost of tech)
    PlayerGateway.subtract_resources_from_player(player_id, {gold: g})
    tech_names.each do |tech_name|
      @game_gateway.research_tech(player_id, tech_name)
    end
    ready_to_found_cities
  end

  def purchase_temples(player_id, city_names)
    verify_player_turn(player_id)
    verify_moving_on_rondel
    city_names.each do |city_name|
      raise "you do not own #{city_name}" if @board_gateway.owner_of(city_name) != player_id
      raise "#{tech_name} already has a temple" if @board_gateway.has_temple?(city_name)
    end
    m = city_names.length * 5
    #move_on_rondel(move_payment + cost of temples)
    PlayerGateway.subtract_resources_from_player(player_id, {marble: m})
    city_names.each do |city_name|
      @board_gateway.build_temple(city_name)
    end
    ready_to_found_cities
  end

  def purchase_troops(player_id, footman_locations, boat_locations)
    verify_player_turn(player_id)
    verify_moving_on_rondel
    footman_locations.each do |city_name|
      raise "you do not own #{city_name}" if @board_gateway.owner_of(city_name) != player_id
      max_troops_in_city = @board_gateway.has_temple?(city_name) ? 3 : 1
      raise "you can only arm #{max_troops_in_city} in #{city_name}" if footman_locations.count(city_name) > max_troops_in_city
      raise "you can not arm footmen in #{city_name}" unless @board_gateway.city_supports_footmen?(city_name)
    end
    boat_locations.each do |city_name|
      raise "you do not own #{city_name}" if @board_gateway.owner_of(city_name) != player_id
      max_troops_in_city = @board_gateway.has_temple?(city_name) ? 3 : 1
      raise "you can only arm #{max_troops_in_city} in #{city_name}" if boat_locations.count(city_name) > max_troops_in_city
      raise "you can not arm boats in #{city_name}" unless @board_gateway.city_supports_boats?(city_name)
    end
    i = footman_locations.length + boat_locations.length
    #move_on_rondel(move_payment + cost of temples)
    PlayerGateway.subtract_resources_from_player(player_id, {iron: i})
    footman_locations.each do |city_name|
      @board_gateway.arm_footman(player_id, city_name)
    end
    boat_locations.each do |city_name|
      @board_gateway.arm_boat(player_id, city_name)
    end
    ready_to_found_cities
  end

  def found_cities(player_id, city_names)
    verify_founding_cities
    city_names.each do |city_name|
      raise 'city already owned' if @board_gateway.owner_of(city_name)
    end
    n = city_names.length
    PlayerGateway.subtract_resources_from_player(player_id, {gold: n, marble: n, iron: n})
    city_names.each do |city_name|
      @board_gateway.found_city(city_name, player_id)
    end
    ready_to_collect_great_people
    #collect_great_people
    #next_turn
  end

  private

  def verify_player_turn(player_id)
    raise 'Not your turn' unless @game_gateway.current_player?(player_id)
  end

  def verify_moving_on_rondel
    raise 'Not time to move on rondel' unless @game_gateway.moving_on_rondel?
  end

  def verify_founding_cities
    raise 'Not time to found cities' unless @game_gateway.founding_cities?
  end

  def ready_to_found_cities
    @game_gateway.ready_to_found_cities
  end

  def ready_to_collect_great_people
    @game_gateway.ready_to_collect_great_people
  end

  # def next_turn
  #   @game_gateway.next_turn
  # end

  def prerequisite_included(tech_names, tech_name)
    case tech_name
    when 'roads'
      tech_names.include?('wheel')
    when 'navigation'
      tech_names.include?('sailing')
    when 'currency'
      tech_names.include?('market')
    when 'democracy'
      tech_names.include?('monarchy')
    else
      true
    end
  end
end