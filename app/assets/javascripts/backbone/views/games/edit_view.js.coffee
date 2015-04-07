Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.EditView extends Backbone.View
  template : JST["backbone/templates/games/edit"]

  events :
    "submit #edit-game" : "update"
    "click #add_player" : "addPlayer"
    "click #start_game" : "startGame"

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
      {},
      success : (player) =>
        @players.add(player)
    )

  startGame : (e) ->
    view = this
    model = @model
    $.ajax
      url: unteekuh.paths.start_game(model.id)
      type: 'POST'
      success: (data, status, response) ->
        model.fetch({
          success: (model, response, options) ->
            view.render()
        })

  viewModel : ->
    $.extend({inPlayerSignup: @model.inPlayerSignup()}, @model.attributes)

  render : ->
    $(@el).html(@template(@viewModel()))

    this.$("form").backboneLink(@model)

    playersView = new Unteekuh.Views.Players.IndexView({el: @$('#players'), players: @players, inPlayerSignup: @model.inPlayerSignup()})
    @players.fetch()
    this.$("#game_board_image").attr("src", unteekuh.paths.assets("assets/orient.jpg"))

    return this
