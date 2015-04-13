class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  # GET /players
  # GET /players.json
  def index
    @players = GameInteractor.new(params[:game_id]).list_players
    respond_to do |format|
      format.json { render json: @players }
    end
  end

  # GET /players/1
  # GET /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create
    @game = Game.find(params['game_id'])
    @player = GameInteractor.new(params['game_id']).add_player(current_user)

    respond_to do |format|
      format.html { redirect_to @player, notice: 'Player was successfully created.' }
      format.json { render json: @player, status: :created, location: game_player_url(@game.id, @player.id)   }
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    @game = Game.find(params['game_id'])

    raise 'game has started' unless @game.player_signup?
    raise 'you can not edit other players' unless @player.user_id == current_user.id

    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render json: @player, status: :ok, location: game_player_url(@game.id, @player.id) }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    raise 'game has started' unless @player.game.player_signup?

    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = PlayerGateway.new(params[:game_id]).find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:id, :name, :color)
    end
end
