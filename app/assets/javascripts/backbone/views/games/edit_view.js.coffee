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
            console.log('success again')
            view.render()
          error:  (model, response, options) ->
            console.log('fail inside')

  viewModel : ->
    $.extend({inPlayerSignup: @model.inPlayerSignup()}, @model.attributes)

  render : ->
    $(@el).html(@template(@viewModel()))

    this.$("form").backboneLink(@model)

    playersView = new Unteekuh.Views.Players.IndexView({el: @$('#players'), players: @players, inPlayerSignup: @model.inPlayerSignup()})
    @players.fetch()


    if (!@model.inPlayerSignup())
      self = this

      c = this.$('#game_board')[0]
      ctx = c.getContext("2d");
      board = new Image();
      board.src = unteekuh.paths.assets("assets/orient.jpg");
      board.onload = ->
        ctx.drawImage(board, 0, 0);

        for tile in self.model.get('tiles')
          self.drawCity(ctx, self.model, tile)

    return this

  drawCity : (ctx, game, tile) ->
    if tile.owner?
      color = @model.playerColor(tile.owner)
      coord = @cityCoordinates(tile.name)
      ctx.fillStyle = color;
      ctx.beginPath();
      ctx.arc(coord.x, coord.y, 8, 0, Math.PI*2, true);
      ctx.closePath();
      ctx.fill();

  cityCoordinates : (city_name) ->
    {
      adane: {x: 908, y: 680},
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
      dyrrhachion: {x: 101, y: 257},
      ephesos: {x: 308, y: 283},
      gerrha: {x: 867, y: 359},
      gordion: {x: 387, y: 194},
      harmotia: {x: 986, y: 241},
      knossos: {x: 289, y: 382},
      leptis_magna: {x: 85, y: 579},
      mecca: {x: 738, y: 580},
      melitene: {x: 512, y: 173},
      memphis: {x: 484, y: 515},
      meroe: {x: 676, y: 740},
      messana: {x: 42, y: 383},
      moscha: {x: 1062, y: 480},
      napoca: {x: 124, y: 55},
      ninive: {x: 624, y: 192},
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
