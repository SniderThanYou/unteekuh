require 'spec_helper'
require 'rails_helper'

describe GamesController do
  describe 'abc' do
    let(:user){Fabricate(:valid_user)}
    before :each do
      sign_in user
    end
    it 'def' do
      expect('a').to eql('a')
    end
  end
end
