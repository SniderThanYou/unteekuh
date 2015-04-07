require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String
  field :player_order, type: Array

  has_many :players, dependent: :destroy
  embeds_one :rondel, autobuild: true
  embeds_one :techs, autobuild: true
  embeds_many :tiles

  module State
    PLAYER_SIGNUP = 'player_signup'
    PLAYING = 'playing'
  end

  state_machine :initial => :player_signup do
    event :start_playing do
      transition :player_signup => :moving_on_rondel
    end
    event :start_building_temples do
      transition :moving_on_rondel => :building_temples
    end
    event :start_arming do
      transition :moving_on_rondel => :arming
    end
    event :start_researching_techs do
      transition :moving_on_rondel => :researching_techs
    end
    event :ready_to_found_cities do
      transition [:moving_on_rondel, :building_temples, :arming, :researching_techs] => :founding_cities
    end
    # event :start_maneuvering do
    #   transition :moving_on_rondel => :maneuvering
    # end
    # event :maveuver_into_hostile_territory do
    #   transition :maneuvering => :waiting_for_combat_decision
    # end
    # event :combat_decided do
    #   transition :waiting_for_combat_decision => :maneuvering
    # end
    # event :finish_maveuvering do
    #   transition :maneuvering => :founding_cities
    # end
    event :ready_to_claim_great_people do
      transition :founding_cities => :claiming_great_people
    end
    # event :next_turn do
    #   transition :claiming_great_people => :moving_on_rondel
    # end
  end

  def as_json(*args)
    puts self.id
    res = super
    res['id'] = res.delete('_id').to_s
    res
  end
end

class Rondel
  include Mongoid::Document
  embedded_in :game
  field :center, type: Array, default: []
  field :iron, type: Array, default: []
  field :temple, type: Array, default: []
  field :gold, type: Array, default: []
  field :maneuver1, type: Array, default: []
  field :arming, type: Array, default: []
  field :marble, type: Array, default: []
  field :know_how, type: Array, default: []
  field :maneuver2, type: Array, default: []
end

class Techs
  include Mongoid::Document
  embedded_in :game
  embeds_one :wheel, autobuild: true
  embeds_one :roads, autobuild: true
  embeds_one :sailing, autobuild: true
  embeds_one :navigation, autobuild: true
  embeds_one :market, autobuild: true
  embeds_one :currency, autobuild: true
  embeds_one :monarchy, autobuild: true
  embeds_one :democracy, autobuild: true
end

class Wheel
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
  embedded_in :techs
end
class Roads
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :techs
end
class Sailing
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
  embedded_in :techs
end
class Navigation
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :techs
end
class Market
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
  embedded_in :techs
end
class Currency
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :techs
end
class Monarchy
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
  embedded_in :techs
end
class Democracy
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :techs
end

class Tile
  include Mongoid::Document
  field :name, type: String
  field :resource, type: String
  field :owner, type: BSON::ObjectId
  field :has_temple, type: Boolean
  field :footmen, type: Array
  field :boats, type: Array
  field :ground_connections, type: Array
  field :water_connections, type: Array

  embedded_in :game
end
