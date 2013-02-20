require 'sinatra'
require 'geocoder'

class HowFar < Sinatra::Application
  enable :sessions
  set :haml, :format => :html5 

  get '/' do
    # Get users location
    @place1 = request.location.city

    # Pick random place
    places = File.open('model/places.txt').readlines

    places += File.open('model/landmarks.txt').readlines

    placeId = rand(places.count)

    @place2 = places[placeId]

    session[:place1] = @place1
    session[:place2] = @place2

    haml :play
  end

  post '/' do

    @guess = params[:distance].to_i
    
    @actual = Geocoder::Calculations.distance_between(session[:place1], session[:place2]).round

    if @guess > @actual
      @difference = @guess - @actual
    else
      @difference = @actual - @guess
    end

    @percent_diff = (@difference.to_f / @actual.to_f) * 100

    if @percent_diff < 1
      @description = "Nicely Googled!"

    elsif @percent_diff < 10
      @description = "Awesome!"

    elsif @percent_diff < 30
      @description = "Not bad!"

    elsif @percent_diff < 50
      @description = "Ok..."

    elsif @percent_diff < 75
      @description = "Maybe time to buy a globe?"

    elsif @percent_diff < 100
      @description = "My Gran can do better than that!"

    else
      @description = "Are you drunk?"

    end

    haml :answer
  end

end