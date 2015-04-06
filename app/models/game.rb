require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String
  field :player_order, type: Array

  has_many :players, dependent: :destroy
  has_one :board, dependent: :destroy

  module State
    PLAYER_SIGNUP = 'player_signup'
    PLAYING = 'playing'
  end

  state_machine :initial => :player_signup do
    event :start_playing do
      transition :player_signup => :moving_on_rondel
    end
    event :ready_to_found_cities do
      transition :moving_on_rondel => :founding_cities
    end
    event :start_maneuvering do
      transition :moving_on_rondel => :maneuvering
    end
    event :maveuver_into_hostile_territory do
      transition :maneuvering => :waiting_for_combat_decision
    end
    event :combat_decided do
      transition :waiting_for_combat_decision => :maneuvering
    end
    event :finish_maveuvering do
      transition :maneuvering => :founding_cities
    end
    event :ready_to_collect_great_people do
      transition :founding_cities => :claiming_great_people
    end
    event :next_turn do
      transition :claiming_great_people => :moving_on_rondel
    end
  end

  def as_json(*args)
    puts self.id
    res = super
    res['id'] = res.delete('_id').to_s
    res
  end
end
