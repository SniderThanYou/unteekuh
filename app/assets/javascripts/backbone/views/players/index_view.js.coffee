Unteekuh.Views.Players ||= {}

class Unteekuh.Views.Players.IndexView extends Backbone.View
  template: JST["backbone/templates/players/index"]

  initialize: () ->
    @options.players.bind('reset', @addAll)
    @options.players.bind('reset', @render);
    @options.players.bind('add', @render);

  addAll: () =>
    @options.players.each(@addOne)

  addOne: (player) =>
    view = new Unteekuh.Views.Players.PlayerView({model : player})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(players: @options.players.toJSON()))
    @addAll()

    return this
