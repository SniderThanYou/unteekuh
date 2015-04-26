class GameGateway
  def initialize(game_id)
    @game_id = game_id
  end

  def find_by_id
    Game.where(id: @game_id).limit(1).first
  end

########################################################
###              player management
########################################################

  def list_players
    find_by_id.players
  end

  def find_player_by_id(player_id)
    find_by_id.players.where(id: player_id).limit(1).first
  end

  def find_player_by_user_id(user_id)
    find_by_id.players.where(user_id: user_id).limit(1).first
  end

  def add_player(user)
    game = find_by_id
    game.players.create(user_id: user.id, name: user.email)
  end

  def randomize_player_order
    game = find_by_id
    game.player_order = player_ids.rotate(1) #TODO shuffle
    game.save
  end

  def current_player?(player_id)
    find_by_id.player_order.first == player_id
  end

  def current_user?(user_id)
    find_by_id.player_order.first == find_player_by_user_id(user_id).id
  end

  def add_resources_to_player(player_id, hash)
    h = resource_hash(hash)
    player = find_player_by_id(player_id)
    player.gold += h[:gold]
    player.marble += h[:marble]
    player.iron += h[:iron]
    player.coins += h[:coins]
    player.save
  end

  def subtract_resources_from_player(player_id, hash)
    h = resource_hash(hash)
    player = find_player_by_id(player_id)
    raise 'not enough minerals' unless has_resources(player, h)
    if player.gold >= h[:gold]
      player.gold -= h[:gold]
    else
      player.coins -= (h[:gold] - player.gold)
      player.gold = 0
    end
    if player.marble >= h[:marble]
      player.marble -= h[:marble]
    else
      player.coins -= (h[:marble] - player.marble)
      player.marble = 0
    end
    if player.iron >= h[:iron]
      player.iron -= h[:iron]
    else
      player.coins -= (h[:iron] - player.iron)
      player.iron = 0
    end
    player.coins -= h[:coins]
    player.save
  end

########################################################
###              board setup
########################################################

  def create_board_tiles(region)
    game = find_by_id
    game.tiles = []
    if region == :orient
      Board::Orient.new.default_tiles.each do |t|
        game.tiles.create(t)
      end
    else
      raise 'only orient is supported at this time'
    end
  end

  def set_starting_cities(region)
    if region == :orient
      pids = player_ids
      all_starts = Board::Orient.starting_cities(pids.length)
      all_starts.each_with_index do |player_cities, i|
        player_cities.each do |city_name|
          tile = tile_by_name(city_name.to_s)
          tile.owner = pids[i]
          tile.save
        end
      end
    else
      raise 'only orient is supported at this time'
    end
  end

  def set_starting_rondel_positions #TODO this can go away
    game = find_by_id
    game.players.each do |p|
      p.rondel_loc = 'center'
    end
    game.save
  end

  def set_starting_techs
    tech = tech_by_name('wheel')
    tech.save
    tech = tech_by_name('road')
    tech.save
    tech = tech_by_name('sailing')
    tech.save
    tech = tech_by_name('navigation')
    tech.save
    tech = tech_by_name('market')
    tech.save
    tech = tech_by_name('currency')
    tech.save
    tech = tech_by_name('monarchy')
    tech.save
    tech = tech_by_name('democracy')
    tech.save
  end

########################################################
###              rondel movement
########################################################

  def cost_to_move_on_rondel(player_id, new_spot)
    old_spot = find_player_by_id(player_id).rondel_loc
    return 0 if old_spot == 'center'
    return 5 if old_spot == new_spot
    rondel_locations = ['iron', 'temple', 'gold', 'maneuver1', 'arming', 'marble', 'know_how', 'maneuver2']
    distance = rondel_locations.rotate(rondel_locations.index(old_spot)).index(new_spot)
    [distance - 3, 0].max
  end

  def move_player_on_rondel(player_id, new_spot)
    player = find_player_by_id(player_id)
    player.rondel_loc = new_spot
    player.save
  end

########################################################
###              gold action
########################################################

  def gold_produced_by(player_id)
    resource_produced_by(player_id, 'gold')
  end

########################################################
###              marble action
########################################################

  def marble_produced_by(player_id)
    resource_produced_by(player_id, 'marble')
  end

########################################################
###              iron action
########################################################

  def iron_produced_by(player_id)
    resource_produced_by(player_id, 'iron')
  end

########################################################
###              know how action
########################################################

  def tech_owned_by_any_players?(tech_name)
    tech_by_name(tech_name).owners.empty?
  end

  def player_has_tech?(player_id, tech_name)
    tech_by_name(tech_name).owners.include?(player_id)
  end

  def gold_cost_of_tech(tech_name)
    tech = tech_by_name(tech_name)
    tech.owners.empty? ? tech.cost_first : tech.cost_rest
  end

  def player_has_prerequisite_for_tech?(player_id, tech_name)
    case tech_name
      when 'road'
        player_has_tech?(player_id, 'wheel')
      when 'navigation'
        player_has_tech?(player_id, 'sailing')
      when 'currency'
        player_has_tech?(player_id, 'market')
      when 'democracy'
        player_has_tech?(player_id, 'monarchy')
      else
        true
    end
  end

  def research_tech(player_id, tech_name)
    tech = tech_by_name(tech_name)
    tech.owners << player_id
    tech.save
  end

########################################################
###              temple action
########################################################

  def has_temple?(city_name)
    tile_by_name(city_name).has_temple
  end

  def build_temple(city_name)
    tile = tile_by_name(city_name)
    tile.has_temple = true
    tile.save
  end

########################################################
###              arming action
########################################################

  def city_supports_footmen?(city_name)
    !tile_by_name(city_name).ground_connections[city_name].nil?
  end

  def city_supports_boats?(city_name)
    !tile_by_name(city_name).water_connections[city_name].nil?
  end

  def arm_footman(city_name, player_id)
    tile = tile_by_name(city_name)
    tile.footmen << player_id
    tile.troops_added_this_turn += 1
    tile.save
  end

  def arm_boat(city_name, player_id)
    tile = tile_by_name(city_name)
    tile.boats << player_id
    tile.troops_added_this_turn += 1
    tile.save
  end

  def troops_added_this_turn(city_name)
    tile_by_name(city_name).troops_added_this_turn
  end

########################################################
###              founding cities
########################################################

  def owner_of(city_name)
    tile_by_name(city_name).owner
  end

  def found_city(city_name, player_id)
    tile = tile_by_name(city_name)
    tile.owner = player_id
    tile.save
  end

########################################################
###              great people
########################################################

  def num_temples_owned(player_id)
    find_by_id.tiles.to_a.count do |tile|
      tile.owner == player_id && tile.has_temple
    end
  end

  def num_cities_owned(player_id)
    find_by_id.tiles.to_a.count do |tile|
      tile.owner == player_id
    end
  end

  def num_seas_sailed(player_id)
    find_by_id.tiles.to_a.count do |tile|
      tile.boats.include? player_id
    end
  end

  def great_kings_owned(player_id)
    find_player_by_id(player_id).great_kings
  end

  def great_scholars_owned(player_id)
    find_player_by_id(player_id).great_scholars
  end

  def great_generals_owned(player_id)
    find_player_by_id(player_id).great_generals
  end

  def great_citizens_owned(player_id)
    find_player_by_id(player_id).great_citizens
  end

  def great_navigators_owned(player_id)
    find_player_by_id(player_id).great_navigators
  end

  def claim_great_king(player_id)
    claim_great_person(player_id, 'king')
  end

  def claim_great_scholar(player_id)
    claim_great_person(player_id, 'scholar')
  end

  def claim_great_general(player_id)
    claim_great_person(player_id, 'general')
  end

  def claim_great_citizen(player_id)
    claim_great_person(player_id, 'citizen')
  end

  def claim_great_navigator(player_id)
    claim_great_person(player_id, 'navigator')
  end

  def claim_most_numerous_great_person(player_id)
    game = find_by_id
    type = %w(king scholar general citizen navigator).max do |a, b|
      game.send("great_#{a}s") <=> game.send("great_#{b}s")
    end
    claim_great_person(player_id, type)
  end

########################################################
###              state stuff
########################################################

  def in_player_signup?
    find_by_id.player_signup?
  end

  def start_playing
    find_by_id.start_playing
  end

  def moving_on_rondel?
    find_by_id.moving_on_rondel?
  end

  def start_building_temples
    find_by_id.start_building_temples
  end

  def building_temples?
    find_by_id.building_temples?
  end

  def start_arming
    add_coin_to_first_player
    find_by_id.start_arming
  end

  def arming?
    find_by_id.arming?
  end

  def start_researching_techs
    find_by_id.start_researching_techs
  end

  def researching_techs?
    find_by_id.researching_techs?
  end

  def ready_to_found_cities
    find_by_id.ready_to_found_cities
  end

  def founding_cities?
    find_by_id.founding_cities?
  end

  def ready_to_claim_great_people
    find_by_id.ready_to_claim_great_people
  end

  def next_turn
    game = self.find_by_id
    game.tiles.each do |tile|
      tile.troops_added_this_turn = 0
    end
    game.player_order.rotate!(1)
    game.next_turn
    add_coin_to_first_player
  end

  private

  def tech_by_name(tech_name)
    find_by_id.tech_panel.send(tech_name)
  end

  def tile_by_name(city_name)
    find_by_id.tiles.select{|t| t.name == city_name}.first
  end

  def player_ids
    find_by_id.players.collect{|p| p.id}
  end

  def resource_produced_by(player_id, resource)
    game = find_by_id
    resources = 0
    game.tiles.each do |tile|
      if tile.owner.to_s == player_id && tile.resource == resource
        resources += tile.has_temple ? 3 : 1
      end
    end
    if game.tech_panel.currency.owners.any? {|id| id.to_s == player_id}
      resources += 2
    elsif game.tech_panel.market.owners.any? {|id| id.to_s == player_id}
      resources += 1
    end
    resources
  end

  def has_resources(player, h)
    used_coins = h[:coins]
    used_coins += h[:gold] - player.gold
    used_coins += h[:marble] - player.marble
    used_coins += h[:iron] - player.iron
    used_coins <= player.coins
  end

  def resource_hash(h)
    r = {}
    r[:gold] = h[:gold] ? h[:gold].to_i : 0
    r[:marble] = h[:marble] ? h[:marble].to_i : 0
    r[:iron] = h[:iron] ? h[:iron].to_i : 0
    r[:coins] = h[:coins] ? h[:coins].to_i : 0
    r
  end

  def add_coin_to_first_player
    add_resources_to_player(find_by_id.player_order.first, {coins: 1})
  end

  def claim_great_person(player_id, type)
    game = find_by_id
    player = find_player_by_id(player_id)
    getter = "great_#{type}s"
    setter = "great_#{type}s="
    game_count = game.send(getter)
    if game_count > 0
      game.send(setter, game_count - 1)
      player_count = player.send(getter)
      player.send(setter, player_count + 1)
      game.save
      player.save
    end
  end
end