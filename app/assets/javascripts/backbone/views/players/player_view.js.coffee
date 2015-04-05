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

  viewModel : ->
    $.extend({inPlayerSignup: @options.inPlayerSignup}, @model.attributes)

  render: ->
    self = this

    $(@el).html(@template(@viewModel()))
    @$('#colorpicker').minicolors({
      hide: ->
        self.model.save({color: this.value})
    })
    return this
