class Unteekuh.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults: ->
    name: null,

  inPlayerSignup: ->
    @get('state') == "player_signup"

  playerColor: (playerId) ->
    for player in @get('players')
      if (player.id == playerId)
        return player.color

  currentPlayerName: ->
    playerId = @get('player_order')[0]
    for player in @get('players')
      if (player.id == playerId)
        return player.name

  currentPlayerId: ->
    @get('player_order')[0]

  start: ->
    url = Routes.start_game_path(@id)
    data = {}
    @sendCommandAndFetch(url, data)

  movePlayerToRondelLoc: (playerId, rondelLoc, payment) ->
    url = Routes.move_on_rondel_game_player(@id, playerId, rondelLoc)
    data = {payment: payment}
    @sendCommandAndFetch(url, data)

  doneFoundingCities: ->
    url = Routes.done_founding_cities_game_player(@id, @currentPlayerId())
    data = {}
    @sendCommandAndFetch(url, data)

  sendCommandAndFetch: (url, data) ->
    $.ajax
      url: url
      data: data
      type: 'POST'
      success: (data, status, response) =>
        @fetch()
      failure: (data, status, response) =>
        @fetch()


class Unteekuh.Collections.GamesCollection extends Backbone.Collection
  model: Unteekuh.Models.Game
  url: -> Routes.games()
