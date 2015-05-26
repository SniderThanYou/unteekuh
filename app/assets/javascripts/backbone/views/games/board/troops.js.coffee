Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.TroopsView extends Backbone.View
  initialize: (options) ->
    @game = options.game
    @stage = options.stage
    @game.bind('sync:end', @render, this)
    @cityCoordinates = @getCityCoordinates()

  render: ->
    @draw(@stage)

  draw: (stage) ->
    for tile in @game.get('tiles')
      cityCoord = @cityCoordinates[tile.name]
      pts = @circularPoints(10, cityCoord.x, cityCoord.y)
      console.log(pts)
      for pt in pts
        @addLegion(stage, 'red', pt.x, pt.y)
#      for troop in tile.troops
#        @addTroopToTile(stage, tile, troop)

  addTroopToTile: (stage, tile, troop) ->
    cityCoord = @cityCoordinates[tile.name]
    color = @game.playerColor(troop.owner_id)
    @addLegion(stage, troop.owner, cityCoord.x, cityCoord.y)

  circularPoints: (numPoints, centerX, centerY) ->
    points = []
    r = 25
    for i in [1..numPoints]
      theta = i / numPoints * 2 * Math.PI
      x = centerX + r * Math.cos(theta)
      y = centerY + r * Math.sin(theta)
      points.push({x: x, y: y})
    points

  addLegion: (stage, color, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginStroke('black').beginFill(color)
    points = [[0, 89],
              [18, 89],
              [23, 74],
              [27, 89],
              [45, 89],
              [40, 71],
              [45, 49],
              [36, 30],
              [30, 28],
              [32, 18],
              [31, 10],
              [28, 7],
              [31, 3],
              [28, 0],
              [21, 0],
              [14, 2],
              [9, 9],
              [10, 14],
              [10, 23],
              [12, 25],
              [12, 29],
              [7, 31],
              [3, 35],
              [1, 46],
              [0, 49],
              [0, 53],
              [6, 57],
              [7, 59],
              [4, 79]]
    shape.graphics.drawPolygon(0, 0, points)
    shape.x = x - 5
    shape.y = y - 12
    shape.scaleX = 0.25
    shape.scaleY = 0.25
    stage.addChild(shape);

  addCity: (stage, ownerId, x, y) ->
    color = @game.playerColor(ownerId)
    shape = new createjs.Shape()
    shape.graphics.beginFill(color)
    shape.graphics.drawCircle(x, y, 11)
    stage.addChild(shape);

    if @game.inBuildingTemples() && @game.currentPlayerId() == ownerId
      shape.on 'mousedown', (evt) =>
        city = @nameOfCity(evt.stageX, evt.stageY)
        if confirm("Build temple in " + city + "?")
          @game.buildTemple(ownerId, city)

  addTempleToCity: (stage, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginStroke('black').beginFill('white')
    shape.graphics.drawPolygon(x, y, [[-4, 5], [-4, -1], [-7, -1], [0, -7], [7, -1], [4, -1], [4, 5], [-4, 5]])
    stage.addChild(shape);

  getCityCoordinates: ->
    {
      adane: {x: 909, y: 681},
      adulis: {x: 805, y: 699},
      alexandria: {x: 440, y: 471},
      ammonion: {x: 380, y: 546},
      antiochia: {x: 531, y: 261},
      artaxata: {x: 620, y: 79},
      athen: {x: 234, y: 320},
      attalia: {x: 400, y: 287},
      babylon: {x: 681, y: 270},
      berenice: {x: 628, y: 584},
      bycantium: {x: 293, y: 185},
      charax: {x: 764, y: 262},
      corniclanum: {x: 216, y: 579},
      cyrene: {x: 240, y: 498},
      dioscoridis: {x: 1110, y: 565},
      dyrrhachion: {x: 102, y: 257},
      ephesos: {x: 308, y: 283},
      gerrha: {x: 867, y: 359},
      gordion: {x: 387, y: 194},
      harmotia: {x: 986, y: 241},
      knossos: {x: 289, y: 382},
      leptis_magna: {x: 85, y: 579},
      mecca: {x: 739, y: 580},
      melitene: {x: 512, y: 173},
      memphis: {x: 484, y: 515},
      meroe: {x: 676, y: 740},
      messana: {x: 43, y: 382},
      moscha: {x: 1062, y: 480},
      napoca: {x: 124, y: 55},
      ninive: {x: 625, y: 192},
      ommana: {x: 1035, y: 313},
      opone: {x: 1074, y: 706},
      palmyra: {x: 604, y: 289},
      paphos: {x: 452, y: 340},
      pella: {x: 172, y: 239},
      persepolis: {x: 881, y: 235},
      petra: {x: 587, y: 433},
      phasis: {x: 545, y: 53},
      punt: {x: 993, y: 687},
      rhagai: {x: 787, y: 131},
      saba: {x: 895, y: 626},
      sinope: {x: 417, y: 109},
      sirmium: {x: 58, y: 122},
      sparta: {x: 205, y: 364},
      susa: {x: 759, y: 210},
      taima: {x: 694, y: 470},
      theben: {x: 550, y: 584},
      tomis: {x: 237, y: 84},
      tyros: {x: 538, y: 359},
      zadrakarta: {x: 817, y: 75}
    }

  nameOfCity: (x, y) ->
    minDistance = 15 * 15;
    for city, coord of @cityCoordinates
      xDist = coord.x - x;
      yDist = coord.y - y;
      distance = xDist*xDist + yDist*yDist;
      if (distance < minDistance)
        return city
    return ''