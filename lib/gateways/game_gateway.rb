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

  def add_player(user)
    game = self.find_by_id
    game.players.create(user_id: user.id, name: user.email)
  end

  def randomize_player_order
    game = self.find_by_id
    game.player_order = player_ids.shuffle
    game.save
  end

  def current_player?(player_id)
    find_by_id.player_order.first == player_id
  end

########################################################
###              board setup
########################################################

  def create_board_tiles(region)
    game = self.find_by_id
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

########################################################
###              gold rondel action
########################################################

  def gold_produced_by(player_id)
    resource_produced_by(player_id, 'gold')
  end

########################################################
###              marble rondel action
########################################################

  def marble_produced_by(player_id)
    resource_produced_by(player_id, 'marble')
  end

########################################################
###              iron rondel action
########################################################

  def iron_produced_by(player_id)
    resource_produced_by(player_id, 'iron')
  end

########################################################
###              know how rondel action
########################################################

  def player_has_tech?(player_id, tech_name)
    tech_by_name(tech_name).owners.include?(player_id)
  end

  def gold_cost_of_tech(tech_name)
    tech = find_by_id.techs.send(tech_name)
    tech.owners.empty? ? tech.cost_first : tech.cost_rest
  end

  def player_has_prerequisite_for_tech?(player_id, tech_name)
    case tech_name
      when 'roads'
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
    tile.save
  end

  def arm_boat(city_name, player_id)
    tile = tile_by_name(city_name)
    tile.boats << player_id
    tile.save
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
    self.find_by_id.player_signup?
  end

  def start_playing
    find_by_id.start_playing
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

  private

  def tech_by_name(tech_name)
    find_by_id.techs.send(tech_name)
  end

  def tile_by_name(city_name)
    find_by_id.tiles.select{|t| t.name == city_name}.first
  end

  def player_ids
    self.find_by_id.players.collect{|p| p.id}
  end

  def resource_produced_by(player_id, resource)
    game = find_by_id
    resources = 0
    game.tiles.each do |tile|
      if tile.owner == player_id && tile.resource == resource
        resources += tile.has_temple ? 3 : 1
      end
    end
    if game.techs.currency.owners.include? player_id
      resources += 2
    elsif game.techs.market.owners.include? player_id
      resources += 1
    end
    resources
  end
end