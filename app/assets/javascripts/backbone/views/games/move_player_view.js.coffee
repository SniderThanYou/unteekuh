class Unteekuh.Views.Games.MovePlayerView extends Backbone.Modal
  template: JST["backbone/templates/games/move_payment"]
  submitEl: '#submit_move'
  cancelEl: '#cancel_move'

  initialize: (options) ->
    @game = options.game
    @player = options.player
    @cost = options.cost
    @rondelLoc = options.rondelLoc
    @model = new Backbone.Model({
      cost: options.cost,
      new_rondel_loc: options.rondelLoc,
      gold: @player.get('gold'),
      iron: @player.get('iron'),
      marble: @player.get('marble'),
      coins: @player.get('coins')
    })

  submit: ->
    payment = {
      gold: @$('#gold_spinner').val(),
      marble: @$('#marble_spinner').val(),
      iron: @$('#iron_spinner').val(),
      coins: @$('#coins_spinner').val()
    }
    @game.movePlayerToRondelLoc(@player.id, @rondelLoc, payment)