require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String

  has_many :players

  def add_player(user)
    player = Player.where({game_id: self.id, user_id: user.id}).first
    puts player
    if player
      player
    else
      players.create(user_id: user.id, name: user.email) unless player
    end
  end

  module State
    PLAYER_SIGNUP = 'player_signup'
    PLAYING = 'playing'
  end

  state_machine :initial => :player_signup do
    event :start_game do
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
