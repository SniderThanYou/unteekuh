class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]
  before_action :verify_turn, only: [:move_on_rondel, :done_founding_cities]

  def index
    render json: GameInteractor.new(params[:game_id]).list_players
  end

  def show
  end

  def new
    @player = Player.new
  end

  def edit
  end

  def create
    @game = Game.find(params['game_id'])
    @player = GameInteractor.new(params['game_id']).add_player(current_user)

    respond_to do |format|
      format.html { redirect_to @player, notice: 'Player was successfully created.' }
      format.json { render json: @player, status: :created, location: game_player_url(@game.id, @player.id)   }
    end
  end

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

  def destroy
    raise 'game has started' unless @player.game.player_signup?

    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def move_on_rondel
    interactor.verify_user_turn(current_user.id)
    interactor.move_on_rondel(params[:id], params[:rondel_loc], params[:payment])
    render nothing: true
  end

  def done_founding_cities
    interactor.finish_founding_cities(params[:id])
    render nothing: true
  end

  private

  def set_player
    @player = PlayerGateway.new(params[:game_id]).find_by_id(params[:id])
  end

  def interactor
    @interactor ||= GameInteractor.new(params[:game_id])
    @interactor
  end

  def player_params
    params.require(:player).permit(:id, :name, :color)
  end

  def verify_turn
    interactor.verify_user_turn(current_user.id)
    interactor.verify_player_turn(params[:id])
  end
end
