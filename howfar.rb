require 'sinatra'
require 'geocoder'

class HowFar < Sinatra::Application
  enable :sessions
  set :haml, :format => :html5 

  get '/' do
    # Get users location
    @place1 = request.location.city

    @place1 = "Northampton, United Kingdom"

    # Pick random place
    places = File.open('model/places.txt').readlines

    placeId = rand(places.count)

    @place2 = places[placeId]

    session[:place1] = @place1
    session[:place2] = @place2

    haml :play
  end

  post '/' do

    @guess = params[:distance]
    
    @actual = Geocoder::Calculations.distance_between(session[:place1], session[:place2])

    haml :answer
  end

end