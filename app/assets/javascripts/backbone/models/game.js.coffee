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
    self = this
    $.ajax
      url: unteekuh.paths.start_game(self.id)
      type: 'POST'
      success: (data, status, response) ->
        self.fetch()

  movePlayerToRondelLoc : (playerId, rondelLoc, payment) ->
    console.log('moving')
    self = this
    payment = {gold: 0, marble: 0, iron: 0, coins: 0}
    $.ajax
      url: unteekuh.paths.move_on_rondel_game_player(self.id, playerId, rondelLoc)
      data: {payment: payment}
      type: 'POST'
      success: (data, status, response) ->
        self.fetch()
      failure: (data, status, response) ->
        self.fetch()

class Unteekuh.Collections.GamesCollection extends Backbone.Collection
  model: Unteekuh.Models.Game
  url: -> unteekuh.paths.games
