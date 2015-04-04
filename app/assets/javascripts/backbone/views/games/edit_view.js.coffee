Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.EditView extends Backbone.View
  template : JST["backbone/templates/games/edit"]

  events :
    "submit #edit-game" : "update"
    "click #add_player" : "addPlayer"

  initialize : (options) ->
    @players = new Unteekuh.Collections.PlayersCollection([], {game_id: @model.id})

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (game) =>
        @model = game
        window.location.hash = "/#{@model.id}"
    )

  addPlayer : (e) ->
    player = new Unteekuh.Models.Player({game_id: @model.id})
    player.save(
      {game_id: @model.id},
      success : (player) =>
        @players.add(player)
    )

  render : ->
    $(@el).html(@template(@model.toJSON()))

    this.$("form").backboneLink(@model)

    playersView = new Unteekuh.Views.Players.IndexView({el: @$('#players'), players: @players})
    @players.fetch()

    return this
