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

  def player_ids
    self.find_by_id.players.collect{|p| p.id}
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

  # def next_turn
  #   game = self.find_by_id
  #   game.player_order.rotate!
  #   game.save
  # end

  private

  def tech_by_name(tech_name)
    find_by_id.techs.send(tech_name)
  end
end