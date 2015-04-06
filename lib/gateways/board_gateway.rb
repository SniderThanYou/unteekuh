class BoardGateway
  def initialize(game_id)
    @game_id = game_id
  end

  def self.create_orient(player_ids)
    board Board::Orient.create!
    board.rondel['center'] = player_ids

    board.save
    board
  end

  def gold_produced_by(player_id)
    resource_produced_by(player_id, 'gold')
  end

  def marble_produced_by(player_id)
    resource_produced_by(player_id, 'marble')
  end

  def iron_produced_by(player_id)
    resource_produced_by(player_id, 'iron')
  end

  def owner_of(city_name)
    find_by_game_id.tiles[city_name]['owner']
  end

  def found_city(city_name, player_id)
    find_by_game_id.tiles[city_name]['owner'] = player_id
  end

  def player_has_tech?(player_id, tech_name)
    find_by_game_id.techs[tech_name]['owners'].include?(player_id)
  end

  def gold_cost_of_tech(tech_name)
    tech = find_by_game_id.techs[tech_name]
    tech['owners'].empty? ? tech['cost_first'] : tech['cost_rest']
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
    board = find_by_game_id
    board.techs[tech_name]['owners'] << player_id
    board.save
  end

  def has_temple?(city_name)
    find_by_game_id.tiles[city_name]['has_temple']
  end

  def build_temple(city_name)
    board = find_by_game_id
    board.tiles[city_name]['has_temple'] = true
    board.save
  end

  def city_supports_footmen?(city_name)
    !find_by_game_id.tiles[city_name]['ground_connections'][city_name].nil?
  end

  def city_supports_boats?(city_name)
    !find_by_game_id.tiles[city_name]['water_connections'][city_name].nil?
  end

  def arm_footman(player_id, city_name)
    board = find_by_game_id
    board.tiles[city_name]['footmen'] << player_id
    board.save
  end

  def arm_boat(player_id, city_name)
    board = find_by_game_id
    board.tiles[city_name]['boats'] << player_id
    board.save
  end

  private

  def find_by_game_id
    Board.where(game_id: @game_id).limit(1).first
  end

  def resource_produced_by(player_id, resource)
    board = find_by_game_id
    resources = 0
    board.tiles.each do |k, tile|
      if tile['owner'] == player_id && tile['resource'] == resource
        resources += tile['has_temple'] ? 3 : 1
      end
    end
    if board.techs['currency']['owners'].include? player_id
      resources += 2
    elsif board.techs['market']['owners'].include? player_id
      resources += 1
    end
    resources
  end
end