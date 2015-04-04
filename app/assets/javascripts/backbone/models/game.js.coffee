class Unteekuh.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults : ->
    name: null
    players: new Unteekuh.Collections.PlayersCollection([], {game_id: @id})

class Unteekuh.Collections.GamesCollection extends Backbone.Collection
  model: Unteekuh.Models.Game
  url: -> unteekuh.paths.games
