Unteekuh.Views.Games ||= {}

class Unteekuh.Views.Games.EditView extends Backbone.View
  template : JST["backbone/templates/games/edit"]

  events :
    "submit #edit-game" : "update"
    "click #add_player" : "addPlayer"
    "click #start_game" : "startGame"

  initialize : (options) ->
    @players = new Unteekuh.Collections.PlayersCollection([], {game_id: @model.id})

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (game) =>
        @model = game
        window.location.hash = "/#{@model.id}"
    )

  addPlayer : (e) ->
    player = new Unteekuh.Models.Player({game_id: @model.id})
    player.save(
      {},
      success : (player) =>
        @players.add(player)
    )

  startGame : (e) ->
    view = this
    $.ajax
      url: unteekuh.paths.start_game(view.model.id)
      type: 'POST'
      success: (data, status, response) ->
        view.model.fetch
          success: (model, response, options) ->
            view.render()

  viewModel : ->
    $.extend({inPlayerSignup: @model.inPlayerSignup()}, @model.attributes)

  render : ->
    $(@el).html(@template(@viewModel()))

    this.$("form").backboneLink(@model)

    playersView = new Unteekuh.Views.Players.IndexView({el: @$('#players'), players: @players, inPlayerSignup: @model.inPlayerSignup()})
    @players.fetch()
    console.log(@model)

    if (!@model.inPlayerSignup())
      self = this

      c = this.$('#game_board')[0]
      ctx = c.getContext("2d");
      board = new Image();
      board.src = unteekuh.paths.assets("assets/orient.jpg");
      board.onload = ->
        ctx.drawImage(board, 0, 0);

        for tile in self.model.get('tiles')
          self.drawTile(ctx, self.model, tile)

        rondel = self.model.get('rondel')
        for rondelLoc, playerIds of rondel
          continue if rondelLoc == 'id'
          for playerId, i in playerIds
            color = self.model.playerColor(playerId)
            coord = self.rondelCoordinates(rondelLoc)[i]
            self.drawPeg(ctx, color, coord.x, coord.y)

#        for r in ['center', 'iron', 'temple', 'gold', 'maneuver1', 'arming', 'marble', 'know_how', 'maneuver2']
#          for coord in self.rondelCoordinates(r)
#            self.drawPeg(ctx, '#FF0000', coord.x, coord.y)

    return this

  drawTile : (ctx, game, tile) ->
    if tile.owner?
      color = @model.playerColor(tile.owner)
      cityCoord = @cityCoordinates(tile.name)
      @drawCity(ctx, color, cityCoord.x, cityCoord.y)

      if tile.has_temple
        @drawTempleOnCity(ctx, @invertColor(color), cityCoord.x, cityCoord.y)

  drawCity : (ctx, color, x, y) ->
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.arc(x, y, 11, 0, Math.PI*2, true);
    ctx.closePath();
    ctx.fill();
      
  drawTempleOnCity : (ctx, color, x, y) ->
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(x - 4, y + 5);
    ctx.lineTo(x - 4, y - 1);
    ctx.lineTo(x - 7, y - 1);
    ctx.lineTo(x, y - 7);
    ctx.lineTo(x + 7, y - 1);
    ctx.lineTo(x + 4, y - 1);
    ctx.lineTo(x + 4, y + 5);
    ctx.closePath();
    ctx.fill();

  invertColor : (hexTripletColor) ->
    color = hexTripletColor;
    color = color.substring(1);
    color = parseInt(color, 16);
    color = 0xFFFFFF ^ color;
    color = color.toString(16);
    color = ("000000" + color).slice(-6);
    color = "#" + color;
    return color;

  cityCoordinates : (city_name) ->
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
      messana: {x: 42, y: 382},
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

  drawPeg : (ctx, color, x, y) ->
    ctx.fillStyle = color;
    ctx.strokeStyle = 'black';
    ctx.beginPath();
    ctx.moveTo(x - 6, y - 3);
    ctx.lineTo(x - 3, y - 6);
    ctx.lineTo(x + 3, y - 6);
    ctx.lineTo(x + 6, y - 3);
    ctx.lineTo(x + 6, y + 3);
    ctx.lineTo(x + 3, y + 6);
    ctx.lineTo(x - 3, y + 6);
    ctx.lineTo(x - 6, y + 3);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

  rondelCoordinates : (rondel_space) ->
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
    }[rondel_space]