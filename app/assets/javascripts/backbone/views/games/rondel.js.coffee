class Unteekuh.Views.Games.RondelView extends Backbone.View
  initialize: (options) ->
    @game = options.game
    @players = options.players
    @stage = options.stage
    @players.bind('sync:end', @render, this)
    @rondelCoordinates = @getRondelCoordinates()
    @rondelDropZoneCoordinates = @getRondelDropZoneCoordinates()

  render: ->
    @addRondelDropZones(@stage)
    @draw(@stage)

  draw: (stage) ->
    rondel = {
      center:    0,
      iron:      0,
      temple:    0,
      gold:      0,
      maneuver1: 0,
      arming:    0,
      marble:    0,
      know_how:  0,
      maneuver2: 0
    }
    for player in @players.models
      rondelLoc = player.get('rondel_loc')
      pegsOnRondelLoc = rondel[rondelLoc]
      coord = @rondelCoordinates[rondelLoc][pegsOnRondelLoc]
      rondel[rondelLoc]++
      @addRondelPeg(stage, player, coord.x, coord.y)

  addRondelDropZones: (stage) ->
    for rondelLoc, coord of @rondelDropZoneCoordinates
      shape = new createjs.Shape()
      shape.graphics.beginStroke('black')
      shape.graphics.drawCircle(coord.x, coord.y, 25)
      stage.addChild(shape)

  addRondelPeg: (stage, player, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginStroke('black').beginFill(player.get('color'))
    shape.graphics.drawPolyStar(0, 0, 6, 8, 0, -22.5)
    shape.x = x
    shape.y = y
    stage.addChild(shape)

    origX = 0
    origY = 0
    shape.on 'mousedown', (evt) ->
      origX = evt.stageX
      origY = evt.stageY
    shape.on 'pressmove', (evt) ->
      evt.target.x = evt.stageX
      evt.target.y = evt.stageY
    shape.on 'pressup', (evt) =>
      rondelLoc = @nameOfRondelDropZone(evt.stageX, evt.stageY)
      evt.target.x = origX
      evt.target.y = origY
      @movePlayer(player, rondelLoc)

  movePlayer: (player, newRondelLoc) ->
    rondelLoc = player.get('rondel_loc')
    cost = @costToMove(rondelLoc, newRondelLoc)
    Backbone.$ = window.$ #TODO why do I need this?
    Modal = Backbone.Modal.extend({
      template: JST["backbone/templates/games/move_payment"],
      submitEl: '#submit_move'
      cancelEl: '#cancel_move'
      initialize: (options) ->
        @game = options.game
        @player = options.player
        @cost = options.cost
        @rondelLoc = options.rondelLoc
        console.log(options)
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
    });
    modalView = new Modal({game: @game, player: player, cost: cost, rondelLoc: newRondelLoc});
    $('#hidden_modal').html(modalView.render().el);

  getRondelCoordinates: ->
    {
      center:    [{x: 1037, y: 114}, {x: 1048, y: 129}, {x: 1037, y: 147}, {x: 1019, y: 147}, {x: 1008, y: 129}, {x: 1019, y: 114}],
      iron:      [{x: 1037, y:  80}, {x: 1037, y:  65}, {x: 1037, y:  50}, {x: 1058, y:  88}, {x: 1068, y:  78}, {x: 1078, y:  68}],
      temple:    [{x: 1071, y: 100}, {x: 1081, y:  90}, {x: 1091, y:  80}, {x: 1078, y: 122}, {x: 1093, y: 122}, {x: 1108, y: 122}],
      gold:      [{x: 1078, y: 140}, {x: 1093, y: 140}, {x: 1108, y: 140}, {x: 1071, y: 161}, {x: 1081, y: 171}, {x: 1091, y: 181}],
      maneuver1: [{x: 1059, y: 174}, {x: 1069, y: 184}, {x: 1079, y: 194}, {x: 1038, y: 180}, {x: 1038, y: 195}, {x: 1038, y: 210}],
      arming:    [{x: 1018, y: 180}, {x: 1018, y: 195}, {x: 1018, y: 210}, {x:  997, y: 174}, {x:  987, y: 184}, {x:  977, y: 194}],
      marble:    [{x:  985, y: 160}, {x:  975, y: 170}, {x:  965, y: 180}, {x:  980, y: 142}, {x:  965, y: 142}, {x:  950, y: 142}],
      know_how:  [{x:  980, y: 120}, {x:  965, y: 120}, {x:  950, y: 120}, {x:  987, y: 103}, {x:  977, y:  93}, {x:  967, y:  83}],
      maneuver2: [{x: 1001, y:  92}, {x:  991, y:  82}, {x:  981, y:  72}, {x: 1017, y:  86}, {x: 1017, y:  71}, {x: 1017, y:  56}],
    }

  getRondelDropZoneCoordinates: ->
    {
      iron:      {x: 1053, y:  70},
      temple:    {x: 1088, y: 106},
      gold:      {x: 1088, y: 156},
      maneuver1: {x: 1053, y: 192},
      arming:    {x: 1003, y: 192},
      marble:    {x:  967, y: 156},
      know_how:  {x:  967, y: 106},
      maneuver2: {x: 1003, y:  70}
    }

  nameOfRondelDropZone: (x, y) ->
    minDistance = 25 * 25;
    for rondelLoc, coord of @rondelDropZoneCoordinates
      xDist = coord.x - x;
      yDist = coord.y - y;
      distance = xDist*xDist + yDist*yDist;
      if (distance < minDistance)
        return rondelLoc
    return ''

  costToMove: (oldLoc, newLoc) ->
    if oldLoc == 'center'
      return 0
    if oldLoc == newLoc
      return 5
    locs = ['iron', 'temple', 'gold', 'maneuver1', 'arming', 'marble', 'know_how', 'maneuver2']
    oldLocIdx = locs.indexOf(oldLoc)
    newLocIdx = locs.indexOf(newLoc)
    dist = newLocIdx - oldLocIdx
    dist += 8 if dist < 0
    return Math.max(dist - 3, 0)