require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String

  has_many :players, dependent: :destroy
  has_one :board, dependent: :destroy

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
