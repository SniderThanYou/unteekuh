require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String
  field :player_order, type: Array
  field :tiles, type: Hash, default: {}
  field :rondel, type: Hash, default: {}

  has_many :players, dependent: :destroy
  has_one :board, dependent: :destroy
  embeds_one :techs, autobuild: true

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

class Techs
  include Mongoid::Document
  embeds_one :wheel
  embeds_one :roads
  embeds_one :sailing
  embeds_one :navigation
  embeds_one :market
  embeds_one :currency
  embeds_one :monarchy
  embeds_one :democracy
end

class TechTier1
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
end

class TechTier2
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
end

class Wheel < TechTier1
  embedded_in :techs
end
class Roads < TechTier2
  embedded_in :techs
end
class Sailing < TechTier1
  embedded_in :techs
end
class Navigation < TechTier2
  embedded_in :techs
end
class Market < TechTier1
  embedded_in :techs
end
class Currency < TechTier2
  embedded_in :techs
end
class Monarchy < TechTier1
  embedded_in :techs
end
class Democracy < TechTier2
  embedded_in :techs
end
