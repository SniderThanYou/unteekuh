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
      troops = tile.troops
      if troops
        pts = @circularPoints(troops.length, cityCoord.x, cityCoord.y)
        for pt, i in pts
          console.log(troops[i])
          color = @game.playerColor(troops[i].owner)
          if troops[i].troop_type == 'legion'
            @addLegion(stage, color, pt.x, pt.y)
          else if troops[i].troop_type == 'galley'
            @addGalley(stage, color, pt.x, pt.y)
          @addLine(stage, pt.x, pt.y, cityCoord.x, cityCoord.y)

  addLine: (stage, x1, y1, x2, y2) ->
    line = new createjs.Shape()
    line.graphics.setStrokeStyle(1).beginStroke('black');
    line.graphics.moveTo(x1, y1)
    line.graphics.lineTo(x2, y2)
    line.graphics.endStroke()
    stage.addChild(line)

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
    points = [[ 0 / 4, 89 / 4],
              [18 / 4, 89 / 4],
              [23 / 4, 74 / 4],
              [27 / 4, 89 / 4],
              [45 / 4, 89 / 4],
              [40 / 4, 71 / 4],
              [45 / 4, 49 / 4],
              [36 / 4, 30 / 4],
              [30 / 4, 28 / 4],
              [32 / 4, 18 / 4],
              [31 / 4, 10 / 4],
              [28 / 4,  7 / 4],
              [31 / 4,  3 / 4],
              [28 / 4,  0 / 4],
              [21 / 4,  0 / 4],
              [14 / 4,  2 / 4],
              [ 9 / 4,  9 / 4],
              [10 / 4, 14 / 4],
              [10 / 4, 23 / 4],
              [12 / 4, 25 / 4],
              [12 / 4, 29 / 4],
              [ 7 / 4, 31 / 4],
              [ 3 / 4, 35 / 4],
              [ 1 / 4, 46 / 4],
              [ 0 / 4, 49 / 4],
              [ 0 / 4, 53 / 4],
              [ 6 / 4, 57 / 4],
              [ 7 / 4, 59 / 4],
              [ 4 / 4, 79 / 4]]
    shape.graphics.drawPolygon(0, 0, points)
    shape.x = x - 5
    shape.y = y - 12
    stage.addChild(shape);

  addGalley: (stage, color, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginStroke('black').beginFill(color)
    points = [[12.5, 0],
              [7.5, 7.5],
              [-7.5, 7.5],
              [-12.5, 0],
              [-1.25, 0],
              [-1.25, -10],
              [1.25, -10],
              [8.75, -2.5],
              [1.25, -2.5],
              [1.25, 0]]
    shape.graphics.drawPolygon(0, 0, points)
    shape.x = x
    shape.y = y
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