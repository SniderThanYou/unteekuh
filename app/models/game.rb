require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String

  has_many :players

  def add_player(user)
    player = Player.where({game_id: self.id, user_id: user.id}).first
    if player && self.player_signup?
      player
    else
      players.create(user_id: user.id, name: user.email) unless player
    end
  end

  def start_game
    self.begin_playing
    @game_board = GameBoard.for_orient
  end

  def found_city(player_id, city_name)
    current_owner_id = @game_board.owner_of(city_name)
    raise 'city already owned' if current_owner_id
    PlayerGateway.subtract_resources_from_player(player_id, {gold: 1, marble: 1, iron: 1})
    @game_board.found_city(city_name, player_id)
  end

  def purchase_tech(player_id, tech_name)
    raise 'you already own that tech' if @game_board.player_has_tech?(player_id, tech_name)
    g = @game_board.gold_cost_of_tech(tech_name)
    PlayerGateway.subtract_resources_from_player(player_id, {gold: g})
  end

  module State
    PLAYER_SIGNUP = 'player_signup'
    PLAYING = 'playing'
  end

  state_machine :initial => :player_signup do
    event :begin_playing do
      transition :player_signup => :playing
    end
  end

  def as_json(*args)
    puts self.id
    res = super
    res['id'] = res.delete('_id').to_s
    res
  end
end
