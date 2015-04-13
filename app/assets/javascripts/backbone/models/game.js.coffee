class Unteekuh.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults : ->
    name: null,

  inPlayerSignup : ->
    @get('state') == "player_signup"

  playerColor : (player_id) ->
    for player in @get('players')
      if (player.user_id == player_id)
        return player.color

class Unteekuh.Collections.GamesCollection extends Backbone.Collection
  model: Unteekuh.Models.Game
  url: -> unteekuh.paths.games
