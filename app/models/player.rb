class Player
  include Mongoid::Document
  field :user_id, type: BSON::ObjectId
  field :name, type: String, default: ''
  field :color, type: String, default: '#ff0000' #hexadecimal, i.e. '#0700FF'

  field :rondel_loc, type: String, default: 'center'

  field :gold, type: Integer, default: 3
  field :marble, type: Integer, default: 2
  field :iron, type: Integer, default: 1
  field :coins, type: Integer, default: 0

  field :great_kings, type: Integer, default: 0
  field :great_scholars, type: Integer, default: 0
  field :great_generals, type: Integer, default: 0
  field :great_citizens, type: Integer, default: 0
  field :great_navigators, type: Integer, default: 0

  field :legion_pool, type: Integer, default: 17
  field :galley_pool, type: Integer, default: 17
  field :city_pool, type: Integer, default: 22 #plus three on the board

  embedded_in :game
end
