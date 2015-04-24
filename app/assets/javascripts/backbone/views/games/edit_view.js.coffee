Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.EditView extends Backbone.View
  template: JST["backbone/templates/games/edit"]

  events:
    "submit #edit-game" : "update"
    "click #add_player" : "addPlayer"
    "click #start_game" : "startGame"
    "click #done_founding_cities" : "doneFoundingCities"

  initialize: (options) ->
    console.log(Routes)
    @model.bind('sync:end', @render, this)
    @players = new Unteekuh.Collections.PlayersCollection([], {game_id: @model.id})

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (game) =>
        @model = game
        window.location.hash = "/#{@model.id}"
    )

  addPlayer: (e) ->
    player = new Unteekuh.Models.Player({game_id: @model.id})
    player.save(
      {},
      success: (player) =>
        @players.add(player)
    )

  startGame: (e) ->
    @model.start()

  doneFoundingCities: (e) ->
    @model.doneFoundingCities()

  viewModel: ->
    $.extend({inPlayerSignup: @model.inPlayerSignup(), current_player: @model.currentPlayerName()}, @model.attributes)

  render: ->
    $(@el).html(@template(@viewModel()))

    this.$("form").backboneLink(@model)

    playersView = new Unteekuh.Views.Players.IndexView({el: @$('#players'), players: @players, inPlayerSignup: @model.inPlayerSignup()})

    stage = new createjs.Stage(@$('#game_board')[0])
    @drawGameBoard(stage) unless @model.inPlayerSignup()

    @players.fetch()

    return this

  drawGameBoard: (stage) ->
    rondel = new Unteekuh.Views.Games.RondelView({stage: stage, game: @model, players: @players})

    @addTiles(stage)
    @addTechs(stage)
    stage.update()

    createjs.Ticker.addEventListener('tick', stage);
    createjs.Ticker.setInterval(25);
    createjs.Ticker.setFPS(60);

  addTiles: (stage) ->
    for tile in @model.get('tiles')
      if tile.owner?
        color = @model.playerColor(tile.owner)
        cityCoord = @cityCoordinates(tile.name)
        @addCity(stage, color, cityCoord.x, cityCoord.y)

        if tile.has_temple
          @addTempleToCity(stage, cityCoord.x, cityCoord.y)

  addCity: (stage, color, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginFill(color)
    shape.graphics.drawCircle(x, y, 11)
    stage.addChild(shape);

  addTempleToCity: (stage, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginStroke('black').beginFill('white')
    shape.graphics.drawPolygon(x, y, [[-4, 5], [-4, -1], [-7, -1], [0, -7], [7, -1], [4, -1], [4, 5], [-4, 5]])
    stage.addChild(shape);

  addTechs: (stage) ->
    techs = @model.get('tech_panel')
    for techName, techDetails of techs
      continue if techName == 'id'
      for playerId, i in techDetails.owners
        color = @model.playerColor(playerId)
        coord = @techCoordinates(techName)[i]
        @addTechPeg(stage, color, coord.x, coord.y)

  addTechPeg: (stage, color, x, y) ->
    shape = new createjs.Shape()
    shape.graphics.beginStroke('black').beginFill(color);
    shape.graphics.drawPolyStar(x, y, 6, 8, 0, -22.5);
    stage.addChild(shape);

  cityCoordinates: (city_name) ->
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
    }[city_name]

  techCoordinates: (rondel_space) ->
    {
      wheel:      [{x:  43, y: 646}, {x:  65, y: 646}, {x:  87, y: 646}, {x:  43, y: 668}, {x:  65, y: 668}, {x:  87, y: 668}],
      sailing:    [{x: 107, y: 646}, {x: 129, y: 646}, {x: 151, y: 646}, {x: 107, y: 668}, {x: 129, y: 668}, {x: 151, y: 668}],
      market:     [{x: 171, y: 646}, {x: 193, y: 646}, {x: 215, y: 646}, {x: 171, y: 668}, {x: 193, y: 668}, {x: 215, y: 668}],
      monarchy:   [{x: 235, y: 646}, {x: 257, y: 646}, {x: 279, y: 646}, {x: 235, y: 668}, {x: 257, y: 668}, {x: 279, y: 668}],
      road:       [{x:  43, y: 718}, {x:  65, y: 718}, {x:  87, y: 718}, {x:  43, y: 740}, {x:  65, y: 740}, {x:  87, y: 740}],
      navigation: [{x: 107, y: 718}, {x: 129, y: 718}, {x: 151, y: 718}, {x: 107, y: 740}, {x: 129, y: 740}, {x: 151, y: 740}],
      currency:   [{x: 171, y: 718}, {x: 193, y: 718}, {x: 215, y: 718}, {x: 171, y: 740}, {x: 193, y: 740}, {x: 215, y: 740}],
      democracy:  [{x: 235, y: 718}, {x: 257, y: 718}, {x: 279, y: 718}, {x: 235, y: 740}, {x: 257, y: 740}, {x: 279, y: 740}],
    }[rondel_space]