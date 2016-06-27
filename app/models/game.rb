require 'state_machine'

class Game
  include Mongoid::Document
  field :name, type: String
  field :player_order, type: Array
  field :great_kings, type: Integer, default: 9
  field :great_scholars, type: Integer, default: 8
  field :great_generals, type: Integer, default: 7
  field :great_citizens, type: Integer, default: 6
  field :great_navigators, type: Integer, default: 5

  embeds_many :players
  embeds_one :tech_panel, autobuild: true
  embeds_many :tiles

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
      transition [:moving_on_rondel, :building_temples, :arming, :researching_techs, :conquering] => :founding_cities
    end
    event :start_maneuvering do
      transition :moving_on_rondel => :maneuvering
    end
    event :start_killing_troops do
      transition :maneuvering => :killing_troops
    end
    event :start_conquering do
      transition :killing_troops => :conquering
    end
    event :ready_to_claim_great_people do
      transition :founding_cities => :claiming_great_people
    end
    event :next_turn do
      transition :claiming_great_people => :moving_on_rondel
    end
  end
end

class TechPanel
  include Mongoid::Document
  embedded_in :game
  embeds_one :wheel, autobuild: true
  embeds_one :road, autobuild: true
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
  embedded_in :tech_panel
end
class Road
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :tech_panel
end
class Sailing
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
  embedded_in :tech_panel
end
class Navigation
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :tech_panel
end
class Market
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
  embedded_in :tech_panel
end
class Currency
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :tech_panel
end
class Monarchy
  include Mongoid::Document
  field :cost_first, type: Integer, default: 7
  field :cost_rest, type: Integer, default: 3
  field :owners, type: Array, default: []
  embedded_in :tech_panel
end
class Democracy
  include Mongoid::Document
  field :cost_first, type: Integer, default: 10
  field :cost_rest, type: Integer, default: 5
  field :owners, type: Array, default: []
  embedded_in :tech_panel
end

class Tile
  include Mongoid::Document
  field :name, type: String
  field :resource, type: String
  field :owner, type: BSON::ObjectId
  field :has_temple, type: Boolean
  field :ground_connections, type: Array
  field :water_connections, type: Array
  field :troops_added_this_turn, type: Integer, default: 0

  embedded_in :game
  embeds_many :troops
end

class Troop
  include Mongoid::Document
  field :troop_type, type: String #legion, galley
  field :owner, type: BSON::ObjectId
  field :movement_points, type: Integer, default: 0

  embedded_in :tile
end
