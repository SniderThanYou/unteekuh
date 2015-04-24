class Unteekuh.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults : ->
    name: null,

  inPlayerSignup : ->
    @get('state') == "player_signup"

  playerColor : (player_id) ->
    for player in @get('players')
      if (player.id == player_id)
        return player.color

  start : ->
    $.ajax
      url: Routes.start_game_path(@id)
      type: 'POST'
      success: (data, status, response) =>
        @fetch()

  movePlayerToRondelLoc : (playerId, rondelLoc, payment) ->
    $.ajax
      url: Routes.move_on_rondel_game_player_path(@id, playerId, rondelLoc)
      data: {payment: payment}
      type: 'POST'
      success: (data, status, response) =>
        @fetch()
      failure: (data, status, response) =>
        @fetch()

class Unteekuh.Collections.GamesCollection extends Backbone.Collection
  model: Unteekuh.Models.Game
  url: -> Routes.games_path()
