require 'spec_helper'
require 'rails_helper'
require 'mongoid_spec_helper'

describe GamesController do
  let(:erik){Fabricate(:erik)}
  let(:chris){Fabricate(:chris)}
  let(:greg){Fabricate(:greg)}
  let(:jason){Fabricate(:jason)}
  before :each do
    sign_in erik
  end

  describe 'create' do
    it 'creates a game' do
      game = create_game
      expect(game['name']).to eql('abc')
      expect(game['id']).to_not be_nil
    end
  end

  def create_game
    post :create, {game: {name: 'abc'}}
    JSON(response.body)
  end

  def add_player_to_game(game, user)

  end
end
