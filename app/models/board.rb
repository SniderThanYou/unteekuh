class Board
  include Mongoid::Document
  field :techs, type: Hash, default: lambda{default_techs}
  field :tiles, type: Hash, default: lambda{default_tiles}
  belongs_to :game

  private

  def default_techs
    {
        'wheel' => {'cost_first' => 7, 'cost_rest' => 3, 'owners' => []},
        'roads' => {'cost_first' => 10, 'cost_rest' => 5, 'owners' => []},
        'sailing' => {'cost_first' => 7, 'cost_rest' => 3, 'owners' => []},
        'navigation' => {'cost_first' => 10, 'cost_rest' => 5, 'owners' => []},
        'market' => {'cost_first' => 7, 'cost_rest' => 3, 'owners' => []},
        'currency' => {'cost_first' => 10, 'cost_rest' => 5, 'owners' => []},
        'monarchy' => {'cost_first' => 7, 'cost_rest' => 3, 'owners' => []},
        'democracy' => {'cost_first' => 10, 'cost_rest' => 5, 'owners' => []}
    }
  end

  def default_tiles
    tiles = {}
    city_names.each do |city|
      tiles[city] = {
          name: city,
          resource: resource_types[city],
          owner: nil,
          has_temple: false,
          footmen: [],
          boats: [],
          ground_connections: land_connections[city],
          water_connections: water_connections[city]
      }
    end
    tiles
  end

  def city_names
    raise 'instantiate Board::Orient or Board::Occident instead of Board'
  end
end

class Board::Orient < Board
  private

  def city_names
    [
        :adane,
        :adulis,
        :alexandria,
        :ammonion,
        :antiochia,
        :artaxata,
        :athen,
        :attalia,
        :babylon,
        :berenice,
        :bycantium,
        :charax,
        :corniclanum,
        :cyrene,
        :dioscoridis,
        :dyrrhachion,
        :ephesos,
        :gerrha,
        :gordion,
        :harmotia,
        :knossos,
        :leptis_magna,
        :mecca,
        :melitene,
        :memphis,
        :meroe,
        :messana,
        :moscha,
        :napoca,
        :ninive,
        :ommana,
        :opone,
        :palmyra,
        :paphos,
        :pella,
        :persepolis,
        :petra,
        :phasis,
        :punt,
        :rhagai,
        :saba,
        :sinope,
        :sirmium,
        :sparta,
        :susa,
        :taima,
        :theben,
        :tomis,
        :tyros,
        :zadrakarta
    ]
  end

  def resource_types
    {
        adane: :iron,
        adulis: :marble,
        alexandria: :marble,
        ammonion: :iron,
        antiochia: :marble,
        artaxata: :marble,
        athen: :gold,
        attalia: :iron,
        babylon: :marble,
        berenice: :iron,
        bycantium: :iron,
        charax: :iron,
        corniclanum: :marble,
        cyrene: :gold,
        dioscoridis: :marble,
        dyrrhachion: :iron,
        ephesos: :marble,
        gerrha: :gold,
        gordion: :gold,
        harmotia: :marble,
        knossos: :iron,
        leptis_magna: :iron,
        mecca: :gold,
        melitene: :gold,
        memphis: :gold,
        meroe: :gold,
        messana: :gold,
        moscha: :gold,
        napoca: :iron,
        ninive: :iron,
        ommana: :iron,
        opone: :iron,
        palmyra: :gold,
        paphos: :gold,
        pella: :marble,
        persepolis: :gold,
        petra: :marble,
        phasis: :iron,
        punt: :gold,
        rhagai: :marble,
        saba: :marble,
        sinope: :marble,
        sirmium: :gold,
        sparta: :marble,
        susa: :gold,
        taima: :iron,
        theben: :marble,
        tomis: :gold,
        tyros: :iron,
        zadrakarta: :iron
    }
  end

  def land_connections
    {
        adane: [:saba, :moscha, :mecca],
        adulis: [:punt, :opone, :meroe, :berenice],
        alexandria: [:tyros, :memphis, :ammonion, :cyrene],
        ammonion: [:alexandria, :memphis, :theben, :corniclanum, :cyrene],
        antiochia: [:melitene, :ninive, :palmyra, :tyros, :attalia],
        artaxata: [:zadrakarta, :susa, :ninive, :melitene, :phasis],
        athen: [:pella, :sparta, :dyrrhachion],
        attalia: [:gordion, :sinope, :melitene, :antiochia, :ephesos],
        babylon: [:susa, :charax, :gerrha, :taima, :palmyra, :ninive],
        berenice: [:adulis, :meroe, :theben, :memphis],
        bycantium: [:tomis, :sinope, :gordion, :ephesos, :pella],
        charax: [:susa, :rhagai, :persepolis, :harmotia, :gerrha, :babylon],
        corniclanum: [:cyrene, :ammonion, :leptis_magna],
        cyrene: [:alexandria, :ammonion, :corniclanum],
        dioscoridis: nil,
        dyrrhachion: [:sirmium, :pella, :athen, :sparta],
        ephesos: [:bycantium, :gordion, :attalia],
        gerrha: [:ommana, :saba, :taima, :babylon, :charax],
        gordion: [:sinope, :attalia, :ephesos, :bycantium],
        harmotia: [:charax, :persepolis],
        knossos: nil,
        leptis_magna: [:corniclanum],
        mecca: [:taima, :saba, :adane, :petra],
        melitene: [:phasis, :artaxata, :ninive, :antiochia, :attalia, :sinope],
        memphis: [:alexandria, :tyros, :petra, :berenice, :theben, :ammonion],
        meroe: [:berenice, :adulis, :theben],
        messana: nil,
        moscha: [:ommana, :adane, :saba],
        napoca: [:tomis, :pella, :sirmium],
        ninive: [:artaxata, :susa, :babylon, :palmyra, :antiochia, :melitene],
        ommana: [:moscha, :saba, :gerrha],
        opone: [:adulis, :punt],
        palmyra: [:ninive, :babylon, :taima, :petra, :tyros, :antiochia],
        paphos: nil,
        pella: [:napoca, :tomis, :bycantium, :athen, :dyrrhachion, :sirmium],
        persepolis: [:harmotia, :charax, :rhagai, :zadrakarta],
        petra: [:palmyra, :taima, :mecca, :memphis, :tyros],
        phasis: [:artaxata, :melitene, :sinope],
        punt: [:opone, :adulis],
        rhagai: [:zadrakarta, :persepolis, :charax, :susa],
        saba: [:gerrha, :ommana, :moscha, :adane, :mecca, :taima],
        sinope: [:phasis, :melitene, :attalia, :gordion, :bycantium],
        sirmium: [:napoca, :pella, :dyrrhachion],
        sparta: [:athen, :dyrrhachion],
        susa: [:zadrakarta, :rhagai, :charax, :babylon, :ninive, :artaxata],
        taima: [:babylon, :gerrha, :saba, :mecca, :petra, :palmyra],
        theben: [:mgerrhaemphis, :berenice, :meroe, :ammonion],
        tomis: [:bycantium, :pella, :napoca],
        tyros: [:antiochia, :palmyra, :petra, :memphis, :alexandria],
        zadrakarta: [:persepolis, :rhagai, :susa, :artaxata]
    }
  end

  def water_connections
    {
        adane: [:moscha, :dioscoridis, :punt, :adulis, :mecca],
        adulis: [:mecca, :adane, :punt, :berenice],
        alexandria: [:paphos, :tyros, :cyrene, :knossos],
        ammonion: nil,
        antiochia: [:tyros, :paphos, :attalia],
        artaxata: nil,
        athen: [:pella, :bycantium, :ephesos, :knossos, :sparta],
        attalia: [:antiochia, :paphos, :ephesos],
        babylon: nil,
        berenice: [:petra, :mecca, :adulis, :memphis],
        bycantium: [:tomis, :sinope, :ephesos, :athen, :pella],
        charax: [:harmotia, :gerrha],
        corniclanum: [:leptis_magna, :cyrene],
        cyrene: [:sparta, :knossos, :alexandria, :corniclanum, :leptis_magna],
        dioscoridis: [:moscha, :opone, :punt, :adane],
        dyrrhachion: [:sparta, :messana],
        ephesos: [:bycantium, :attalia, :paphos, :knossos, :athen],
        gerrha: [:harmotia, :ommana, :charax],
        gordion: nil,
        harmotia: [:ommana, :gerrha, :charax],
        knossos: [:ephesos, :paphos, :alexandria, :cyrene, :sparta, :athen],
        leptis_magna: [:messana, :sparta, :cyrene, :corniclanum],
        mecca: [:adane, :adulis, :berenice, :petra],
        melitene: nil,
        memphis: [:petra, :berenice],
        meroe: nil,
        messana: [:dyrrhachion, :sparta, :leptis_magna],
        moscha: [:ommana, :dioscoridis, :adane],
        napoca: nil,
        ninive: nil,
        ommana: [:harmotia, :moscha, :gerrha],
        opone: [:punt, :dioscoridis],
        palmyra: nil,
        paphos: [:attalia, :antiochia, :tyros, :alexandria, :knossos, :ephesos],
        pella: [:bycantium, :athen],
        persepolis: nil,
        petra: [:mecca, :berenice, :memphis],
        phasis: [:sinope, :tomis],
        punt: [:adane, :dioscoridis, :opone, :adulis],
        rhagai: nil,
        saba: nil,
        sinope: [:phasis, :bycantium, :tomis],
        sirmium: nil,
        sparta: [:athen, :knossos, :cyrene, :leptis_magna, :messana, :dyrrhachion],
        susa: nil,
        taima: nil,
        theben: nil,
        tomis: [:phasis, :sinope, :bycantium],
        tyros: [:alexandria, :paphos, :antiochia],
        zadrakarta: nil
    }
  end
end

# class Tile
#   include Mongoid::Document
#   field :name, type: String
#   field :resource, type: String
#   field :owner, type: BSON::ObjectId, default: nil
#   field :has_temple, type: Boolean, default: false
#   field :ground_connections, type: Array, default: []
#   field :water_connections, type: Array, default: []
#   embeds_many :footmen
#   embeds_many :boats
# end
#
# class Footman
#   include Mongoid::Document
#   embedded_in :tile
# end
#
# class Boat
#   include Mongoid::Document
#   embedded_in :tile
# end