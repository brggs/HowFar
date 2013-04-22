require 'sinatra'

require './model/howfargame'

class HowFar < Sinatra::Application
  enable :sessions
  set :haml, :format => :html5 

  get '/' do
    # Get users location
    @place1 = request.location.city
    @place1 = 'London'

    # Pick random place
    @place2 = HowFarGame.random_location

    session[:place1] = @place1
    session[:place2] = @place2

    haml :play
  end

  post '/' do

    @guess = params[:distance].to_i
    
    result = HowFarGame.calculate_difference(session[:place1], session[:place2], @guess)

    @actual = result[:actual]
    @difference = result[:difference]
    @description = result[:description]

    haml :answer
  end

  get '/headtohead' do

    session[:p1_score] = 0 if session[:p1_score].nil?
    session[:p2_score] = 0 if session[:p2_score].nil?

    # Get users location
    @place1 = request.location.city
    @place1 = 'London'

    # Pick random place
    @place2 = HowFarGame.random_location

    session[:place1] = @place1
    session[:place2] = @place2

    haml :headtohead
  end

  post '/headtohead' do

    @p1_guess = params[:p1_distance].to_i
    @p2_guess = params[:p2_distance].to_i
    
    p1_result = HowFarGame.calculate_difference(session[:place1], session[:place2], @p1_guess)
    p2_result = HowFarGame.calculate_difference(session[:place1], session[:place2], @p2_guess)

    @actual = p1_result[:actual]

    @p1_difference = p1_result[:difference]
    @p1_description = p1_result[:description]

    @p2_difference = p2_result[:difference]
    @p2_description = p2_result[:description]

    if @p1_difference < @p2_difference
      session[:p1_score] += 1
    elsif @p1_difference > @p2_difference      
      session[:p2_score] += 1
    end

    haml :headtohead_answer
  end

  get '/headtohead_reset' do

    session[:p1_score] = 0
    session[:p2_score] = 0

    redirect '/headtohead'
  end

end