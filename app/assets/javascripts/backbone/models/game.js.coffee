class Unteekuh.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults : ->
    name: null,
    state: null

  inPlayerSignup : ->
    @get('state') == "player_signup"

class Unteekuh.Collections.GamesCollection extends Backbone.Collection
  model: Unteekuh.Models.Game
  url: -> unteekuh.paths.games
