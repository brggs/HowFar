require 'test/unit'
require 'rack/test'
require 'geocoder'

class HowFarTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_all_model_values_are_supported_by_geocoder

    places = File.open('model/places.txt').readlines
    places += File.open('model/landmarks.txt').readlines

    places.each do |e|
    	g = Geocoder::search(e)

    	assert_not_nil(g[0], "Could not find geo data for #{e}")

    	sleep 1
    end

  end
end