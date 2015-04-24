ENV['RAILS_ENV'] ||= 'test'
require 'mongoid'

Mongoid.load!(File.expand_path('../../config/mongoid.yml', __FILE__), :test)

RSpec.configure do |config|
  #Retain pre-test data in development/production environments; purge in test to maintain cleanliness and to run faster
  if ENV['RAILS_ENV'] == 'test'
    config.before(:each) { Mongoid.purge! }
    config.after(:suite) { Mongoid.purge! }
  end
end