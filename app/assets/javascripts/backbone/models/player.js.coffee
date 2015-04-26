class Unteekuh.Models.Player extends Backbone.Model
  paramRoot: 'player'
  urlRoot: -> Routes.game_players(@attributes.game_id)

  defaults:
    game_id: null
    name: null
    color: null
    gold: null
    marble: null
    iron: null
    coins: null
    great_kings: null
    great_scholars: null
    great_generals: null
    great_citizens: null
    great_navigators: null
    legion_pool: null
    galley_pool: null
    city_pool: null

class Unteekuh.Collections.PlayersCollection extends Backbone.Collection
  model: Unteekuh.Models.Player

  initialize: (models, options) ->
    @url = Routes.game_players(options.game_id);
