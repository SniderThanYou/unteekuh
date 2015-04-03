require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String

  embeds_many :players

  def add_player(user)
    players.create(user_id: user.id, name: user.email) unless players.detect { |x| x.user_id == user.id }
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
end
