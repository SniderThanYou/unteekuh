class GameInteractor
  def initialize(game_id)
    @game_id = game_id
    @game_gateway = GameGateway.new(@game_id)
  end

  def list_players
    @game_gateway.list_players
  end

  def add_player(user)
    verify_in_player_signup
    verify_user_not_already_playing(user)
    @game_gateway.add_player(user)
  end

  def start_game
    verify_in_player_signup
    @game_gateway.randomize_player_order
    @game_gateway.create_board_tiles(:orient)
    @game_gateway.set_starting_cities(:orient)
    @game_gateway.set_starting_rondel_positions
    @game_gateway.set_starting_techs
    @game_gateway.start_playing
  end

  def move_on_rondel(player_id, new_spot, move_payment)
    verify_player_turn(player_id)
    verify_moving_on_rondel
    total_payment = move_payment.values.inject(0){|sum,x| sum + x.to_i }
    cost = @game_gateway.cost_to_move_on_rondel(new_spot)
    raise 'Each spot past the third costs one resource' unless total_payment == cost

    @game_gateway.subtract_resources_from_player(player_id, move_payment)
    @game_gateway.move_player_on_rondel(player_id, new_spot)

    case new_spot
      when 'iron'
        collect_iron(player_id)
      when 'temple'
        start_building_temples
      when 'gold'
        collect_gold(player_id)
      when 'maneuver1'
      when 'arming'
        start_arming
      when 'marble'
        collect_marble(player_id)
      when 'know_how'
        start_researching_techs
      when 'maneuver2'
      else
        raise 'Invalid new spot'
    end
  end

  def build_temple(player_id, city_name)
    verify_player_turn(player_id)
    verify_building_temples
    verify_player_owns_city(player_id, city_name)
    verify_city_has_no_temple(city_name)
    @game_gateway.subtract_resources_from_player(player_id, {marble: 5})
    @game_gateway.build_temple(city_name)
  end

  def finish_building_temples(player_id)
    verify_player_turn(player_id)
    verify_building_temples
    ready_to_found_cities
  end

  def arm_footman(player_id, city_name)
    verify_player_turn(player_id)
    verify_arming
    verify_player_owns_city(player_id, city_name)
    verify_city_supports_footmen(city_name)
    verify_more_troops_can_be_added_this_turn(city_name)
    @game_gateway.subtract_resources_from_player(player_id, {iron: 1})
    @game_gateway.arm_footman(city_name, player_id)
  end

  def arm_boat(player_id, city_name)
    verify_player_turn(player_id)
    verify_arming
    verify_player_owns_city(player_id, city_name)
    verify_city_supports_boats(city_name)
    verify_more_troops_can_be_added_this_turn(city_name)
    @game_gateway.subtract_resources_from_player(player_id, {iron: 1})
    @game_gateway.arm_boat(city_name, player_id)
  end

  def finish_arming(player_id)
    verify_player_turn(player_id)
    verify_arming
    ready_to_found_cities
  end

  def research_tech(player_id, tech_name)
    verify_player_turn(player_id)
    verify_researching_tech
    verify_player_does_not_own_tech(player_id, tech_name)
    verify_player_has_prerequisite_tech(player_id, tech_name)
    g = @game_gateway.gold_cost_of_tech(tech_name)
    @game_gateway.subtract_resources_from_player(player_id, {gold: g})
    @game_gateway.research_tech(player_id, tech_name)
  end

  def finish_researching_techs(player_id)
    verify_player_turn(player_id)
    verify_researching_tech
    ready_to_found_cities
  end

  def found_city(player_id, city_name)
    verify_player_turn(player_id)
    verify_founding_cities
    verify_city_unowned(city_name)
    @game_gateway.subtract_resources_from_player(player_id, {gold: 1, marble: 1, iron: 1})
    @game_gateway.found_city(city_name, player_id)
  end

  def finish_founding_cities(player_id)
    verify_player_turn(player_id)
    verify_founding_cities
    ready_to_claim_great_people
  end

  private

  def verify_in_player_signup
    raise 'Players can only be added during the player signup phase' unless @game_gateway.in_player_signup?
  end

  def verify_user_not_already_playing(user)
    raise 'You are already in this game' if @game_gateway.find_player_by_user_id(user.id)
  end

  def verify_player_turn(player_id)
    raise 'Not your turn' unless @game_gateway.current_player?(player_id)
  end

  def verify_moving_on_rondel
    raise 'Not time to move on rondel' unless @game_gateway.moving_on_rondel?
  end

  def verify_founding_cities
    raise 'Not time to found cities' unless @game_gateway.founding_cities?
  end

  def collect_gold(player_id)
    g = @game_gateway.gold_produced_by(player_id)
    @game_gateway.add_resources_to_player(player_id, {gold: g})
    ready_to_found_cities
  end

  def collect_marble(player_id)
    m = @game_gateway.marble_produced_by(player_id)
    @game_gateway.add_resources_to_player(player_id, {marble: m})
    ready_to_found_cities
  end

  def collect_iron(player_id)
    i = @game_gateway.iron_produced_by(player_id)
    @game_gateway.add_resources_to_player(player_id, {iron: i})
    ready_to_found_cities
  end

  def start_building_temples
    @game_gateway.start_building_temples
  end

  def start_arming
    @game_gateway.start_arming
  end

  def start_researching_techs
    @game_gateway.start_researching_techs
  end

  def verify_building_temples
    raise 'Not time to build a temple' unless @game_gateway.building_temples?
  end

  def verify_player_owns_city(player_id, city_name)
    raise "You do not own #{city_name}" unless @game_gateway.owner_of(city_name) == player_id
  end

  def verify_city_has_no_temple(city_name)
    raise "#{city_name} already has a temple" unless @game_gateway.has_temple?(city_name)
  end

  def verify_researching_tech
    raise 'Not time to research a tech' unless @game_gateway.researching_techs?
  end

  def verify_player_does_not_own_tech(player_id, tech_name)
    raise "You already own #{tech_name}" if @game_gateway.player_has_tech?(player_id, tech_name)
  end

  def verify_player_has_prerequisite_tech(player_id, tech_name)
    raise "You do not own the prerequisite for #{tech_name}" unless @game_gateway.player_has_prerequisite_for_tech?(player_id, tech_name)
  end

  def verify_arming
    raise 'Not time to arm' unless @game_gateway.arming?
  end

  def verify_city_supports_footmen(city_name)
    raise "you can not arm footmen in #{city_name}" unless @game_gateway.city_supports_footmen?(city_name)
  end

  def verify_city_supports_boats(city_name)
    raise "you can not arm boats in #{city_name}" unless @game_gateway.city_supports_boats?(city_name)
  end

  def verify_more_troops_can_be_added_this_turn(city_name)
    max_troops_in_city = @game_gateway.has_temple?(city_name) ? 3 : 1
    max_capacity = @game_gateway.troops_added_this_turn(city_name) >= max_troops_in_city
    raise "You can only arm #{max_troops_in_city} in #{city_name} per turn" if max_capacity
  end

  def ready_to_found_cities
    @game_gateway.ready_to_found_cities
  end

  def verify_city_unowned(city_name)
    raise "#{city_name} is already owned" unless @game_gateway.owner_of(city_name).nil?
  end

  def ready_to_claim_great_people
    @game_gateway.ready_to_claim_great_people
  end

  # def next_turn
  #   @game_gateway.next_turn
  # end
end