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
    find_by_id.players.where(user_id: user_id).first
  end

  def add_player(user)
    game = find_by_id
    game.players.create(user_id: user.id, name: user.email)
  end

  def randomize_player_order
    game = find_by_id
    game.player_order = player_ids.rotate(1)
    game.save
  end

  def current_player?(player_id)
    find_by_id.player_order.first.to_s == player_id
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

  def set_starting_rondel_positions
    game = find_by_id
    game.rondel.center = player_ids
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

  def rondel_location_of_player(player_id)
    rondel = find_by_id.rondel
    return 'center' if rondel.center.any? {|id| id.to_s == player_id}
    return 'iron' if rondel.iron.any? {|id| id.to_s == player_id}
    return 'temple' if rondel.temple.any? {|id| id.to_s == player_id}
    return 'gold' if rondel.gold.any? {|id| id.to_s == player_id}
    return 'maneuver1' if rondel.maneuver1.any? {|id| id.to_s == player_id}
    return 'arming' if rondel.arming.any? {|id| id.to_s == player_id}
    return 'marble' if rondel.marble.any? {|id| id.to_s == player_id}
    return 'know_how' if rondel.know_how.any? {|id| id.to_s == player_id}
    return 'maneuver2' if rondel.maneuver2.any? {|id| id.to_s == player_id}
    raise 'player is not on the rondel'
  end

  def cost_to_move_on_rondel(old_spot, new_spot)
    return 0 if old_spot == 'center'
    return 5 if old_spot == new_spot
    rondel_locations = ['iron', 'temple', 'gold', 'maneuver1', 'arming', 'marble', 'know_how', 'maneuver2']
    distance = rondel_locations.rotate(rondel_locations.index(old_spot)).index(new_spot)
    [distance - 3, 0].max
  end

  def move_player_on_rondel(player_id, old_spot, new_spot)
    rondel = find_by_id.rondel
    rondel.send(old_spot).reject!{|x| x.to_s == player_id}
    rondel.send(new_spot) << player_id
    rondel.save
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

  # def next_turn
  #   tile = tile_by_name(city_name)
  #   tile.troops_added_this_turn = 0
  #   tile.save
  #   game = self.find_by_id
  #   game.player_order.rotate!(-1)
  #   game.save
  # end

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
    {
        gold: 0,
        marble: 0,
        iron: 0,
        coins: 0
    }.merge(h)
  end
end