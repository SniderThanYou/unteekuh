Unteekuh.Views.Players ||= {}

class Unteekuh.Views.Players.PlayerView extends Backbone.View
  template: JST["backbone/templates/players/player"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    self = this

    $(@el).html(@template(@model.toJSON()))
    @$('#colorpicker').minicolors({
      hide: ->
        self.model.save({color: this.value})
    })
    return this
