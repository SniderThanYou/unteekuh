Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.EditView extends Backbone.View
  template: JST["backbone/templates/games/edit"]

  events:
    "submit #edit-game" : "update"
    "click #add_player" : "addPlayer"
    "click #start_game" : "startGame"
    "click #done_founding_cities" : "doneFoundingCities"
    "click #done_building_temples" : "doneBuildingTemples"
    "click #done_arming" : "doneArming"
    "click #done_researching_techs" : "doneResearchingTechs"

  initialize: (options) ->
    @model.bind('sync:end', @render, this)
    @players = new Unteekuh.Collections.PlayersCollection([], {game_id: @model.id})

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (game) =>
        @model = game
        window.location.hash = "/#{@model.id}"
    )

  addPlayer: (e) ->
    player = new Unteekuh.Models.Player({game_id: @model.id})
    player.save(
      {},
      success: (player) =>
        @players.add(player)
    )

  startGame: (e) ->
    @model.start()

  doneFoundingCities: (e) ->
    @model.doneFoundingCities()

  doneBuildingTemples: (e) ->
    @model.doneBuildingTemples()

  doneArming: (e) ->
    @model.doneArming()

  doneResearchingTechs: (e) ->
    @model.doneResearchingTechs()

  viewModel: ->
    $.extend({inPlayerSignup: @model.inPlayerSignup(), current_player: @model.currentPlayerName()}, @model.attributes)

  render: ->
    console.log(@model)
    $(@el).html(@template(@viewModel()))

    this.$("form").backboneLink(@model)

    playersView = new Unteekuh.Views.Players.IndexView({el: @$('#players'), players: @players, inPlayerSignup: @model.inPlayerSignup()})

    stage = new createjs.Stage(@$('#game_board')[0])
    @drawGameBoard(stage) unless @model.inPlayerSignup()

    @players.fetch()

    return this

  drawGameBoard: (stage) ->
    rondel = new Unteekuh.Views.Games.RondelView({stage: stage, game: @model, players: @players})
    cities = new Unteekuh.Views.Games.CitiesView({stage: stage, game: @model})
    cities.render()
    techs = new Unteekuh.Views.Games.TechsView({stage: stage, game: @model})
    techs.render()
    troops = new Unteekuh.Views.Games.TroopsView({stage: stage, game: @model, players: @players})
    troops.render()

    stage.update()

    createjs.Ticker.addEventListener('tick', stage);
    createjs.Ticker.setInterval(25);
    createjs.Ticker.setFPS(60);
