Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.GameView extends Backbone.View
  template: JST["backbone/templates/games/game"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    if confirm "Do you really want to destroy this game?"
      @model.destroy()
      this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
