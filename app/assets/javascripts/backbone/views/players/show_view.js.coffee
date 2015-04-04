Unteekuh.Views.Players ||= {}

class Unteekuh.Views.Players.ShowView extends Backbone.View
  template: JST["backbone/templates/players/show"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
