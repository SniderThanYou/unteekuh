class Unteekuh.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults : ->
    name: null,

  inPlayerSignup : ->
    @get('state') == "player_signup"

  start : ->
    self = this
    $.ajax
      url: unteekuh.paths.start_game(self.id)
      type: 'POST'
      success: (data, status, response) ->
        self.fetch()

  playerColor : (player_id) ->
    for player in @get('players')
      if (player.id == player_id)
        return player.color

class Unteekuh.Collections.GamesCollection extends Backbone.Collection
  model: Unteekuh.Models.Game
  url: -> unteekuh.paths.games
