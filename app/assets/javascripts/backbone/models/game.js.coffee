class Unteekuh.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults: ->
    name: null,

  inPlayerSignup: ->
    @get('state') == "player_signup"

  inMovingOnRondel: ->
    @get('state') == "moving_on_rondel"

  inBuildingTemples: ->
    @get('state') == "building_temples"

  inArming: ->
    @get('state') == "arming"

  inResearchingTechs: ->
    @get('state') == "researching_techs"

  playerColor: (playerId) ->
    for player in @get('players')
      if player.id == playerId
        return player.color

  currentPlayerName: ->
    return '' unless @get('players')
    playerId = @currentPlayerId()
    for player in @get('players')
      if player.id == playerId
        return player.name
    return ''

  currentPlayerId: ->
    if @get('player_order') then @get('player_order')[0] else ''

  start: ->
    url = Routes.start_game(@id)
    data = {}
    @sendCommandAndFetch(url, data)

  movePlayerToRondelLoc: (playerId, rondelLoc, payment) ->
    url = Routes.move_on_rondel_game_player(@id, playerId, rondelLoc)
    data = {payment: payment}
    @sendCommandAndFetch(url, data)

  buildTemple: (playerId, city) ->
    url = Routes.build_temple_game_player(@id, playerId, city)
    data = {}
    @sendCommandAndFetch(url, data)

  doneBuildingTemples: ->
    url = Routes.done_building_temples_game_player(@id, @currentPlayerId())
    data = {}
    @sendCommandAndFetch(url, data)

  armFootman: (playerId, city) ->
    url = Routes.arm_footman_game_player(@id, playerId, city)
    data = {}
    @sendCommandAndFetch(url, data)

  armBoat: (playerId, city) ->
    url = Routes.arm_boat_game_player(@id, playerId, city)
    data = {}
    @sendCommandAndFetch(url, data)

  doneArming: ->
    url = Routes.done_arming_game_player(@id, @currentPlayerId())
    data = {}
    @sendCommandAndFetch(url, data)

  researchTech: (playerId, tech) ->
    url = Routes.research_tech_game_player(@id, playerId, tech)
    data = {}
    @sendCommandAndFetch(url, data)

  doneResearchingTechs: ->
    url = Routes.done_researching_techs_game_player(@id, @currentPlayerId())
    data = {}
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
