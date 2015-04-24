require 'spec_helper'
require 'rails_helper'
require 'mongoid_spec_helper'

describe GamesController do
  let(:user){Fabricate(:valid_user)}
  before :each do
    sign_in user
  end

  describe 'create' do
    it 'creates a game' do
      create_game
      g = JSON(response.body)
      expect(g['name']).to eql('abc')
      expect(g['id']).to_not be_nil
    end
  end

  def create_game
    post :create, {game: {name: 'abc'}}
  end
end
