class Player
  include Mongoid::Document
  field :user_id, type: BSON::ObjectId
  field :name, type: String, default: ''
  field :color, type: String, default: '#ff0000' #hexadecimal, i.e. '#0700FF'

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

  field :wheel_level, type: Integer, default: 0
  field :sailing_level, type: Integer, default: 0
  field :market_level, type: Integer, default: 0
  field :monarchy_level, type: Integer, default: 0

  embedded_in :game

  def as_json(options={})
    attrs = super(options)
    attrs['game_id'] = game.id.to_s
    attrs
  end
end
