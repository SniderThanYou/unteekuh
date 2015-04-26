Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.TechsView extends Backbone.View
  initialize: (options) ->
    @game = options.game
    @stage = options.stage
    @game.bind('sync:end', @render, this)
    @techCoordinates = @getTechCoordinates()
    @techBoxes = @getTechBoxes()

  render: ->
    @draw(@stage)

  draw: (stage) ->
    techs = @game.get('tech_panel')
    for techName, techDetails of techs
      continue if techName == 'id'
      for playerId, i in techDetails.owners
        color = @game.playerColor(playerId)
        coord = @techCoordinates[techName][i]
        @addTechPeg(stage, color, coord.x, coord.y)
    if @game.inResearchingTechs()
      @addTechBoxes(stage)

  addTechPeg: (stage, color, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginStroke('black').beginFill(color)
    shape.graphics.drawPolyStar(x, y, 6, 8, 0, -22.5)
    stage.addChild(shape)

  addTechBoxes: (stage) ->
    for tech, rect of @techBoxes
      shape = new createjs.Shape()
      shape.graphics.beginStroke("black")
      shape.graphics.drawRect(rect.x, rect.y, rect.width, rect.height)
      hit = new createjs.Shape()
      hit.graphics.beginFill("#000").drawRect(rect.x, rect.y, rect.width, rect.height);
      shape.hitArea = hit
      stage.addChild(shape)

      shape.on 'mousedown', (evt) =>
        techName = @nameOfTechBox(evt.stageX, evt.stageY)
        if confirm("Research " + techName + "?")
          @game.researchTech(@game.currentPlayerId(), techName)

  getTechCoordinates: ->
    {
      wheel:      [{x:  43, y: 646}, {x:  65, y: 646}, {x:  87, y: 646}, {x:  43, y: 668}, {x:  65, y: 668}, {x:  87, y: 668}],
      sailing:    [{x: 107, y: 646}, {x: 129, y: 646}, {x: 151, y: 646}, {x: 107, y: 668}, {x: 129, y: 668}, {x: 151, y: 668}],
      market:     [{x: 171, y: 646}, {x: 193, y: 646}, {x: 215, y: 646}, {x: 171, y: 668}, {x: 193, y: 668}, {x: 215, y: 668}],
      monarchy:   [{x: 235, y: 646}, {x: 257, y: 646}, {x: 279, y: 646}, {x: 235, y: 668}, {x: 257, y: 668}, {x: 279, y: 668}],
      road:       [{x:  43, y: 718}, {x:  65, y: 718}, {x:  87, y: 718}, {x:  43, y: 740}, {x:  65, y: 740}, {x:  87, y: 740}],
      navigation: [{x: 107, y: 718}, {x: 129, y: 718}, {x: 151, y: 718}, {x: 107, y: 740}, {x: 129, y: 740}, {x: 151, y: 740}],
      currency:   [{x: 171, y: 718}, {x: 193, y: 718}, {x: 215, y: 718}, {x: 171, y: 740}, {x: 193, y: 740}, {x: 215, y: 740}],
      democracy:  [{x: 235, y: 718}, {x: 257, y: 718}, {x: 279, y: 718}, {x: 235, y: 740}, {x: 257, y: 740}, {x: 279, y: 740}],
    }

  getTechBoxes: ->
    {
      wheel:      new createjs.Rectangle( 34, 626, 61, 66),
      sailing:    new createjs.Rectangle( 98, 626, 61, 66),
      market:     new createjs.Rectangle(161, 626, 61, 66),
      monarchy:   new createjs.Rectangle(224, 626, 61, 66),
      road:       new createjs.Rectangle( 34, 694, 61, 66),
      navigation: new createjs.Rectangle( 98, 694, 61, 66),
      currency:   new createjs.Rectangle(161, 694, 61, 66),
      democracy:  new createjs.Rectangle(224, 694, 61, 66)
    }

  nameOfTechBox: (x, y) ->
    for tech, box of @techBoxes
      if box.contains(x, y)
        return tech
    return ''