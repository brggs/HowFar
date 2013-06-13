require 'sinatra'
require 'mongo'
require 'omniauth-twitter'
require './model/howfargame'

class HowFar < Sinatra::Application
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :haml, :format => :html5 

  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  end

  before do
    @db = Mongo::Connection.new("localhost", 27017).db("howfardb")
    @user = @db['users'].find_one("user_id" => session[:uid]) unless session[:uid].nil?
  end

  get '/' do
    # Check for existing game
    @game = HowFarGame.current_game(session[:uid])

    haml :index
  end

  get '/new' do
    redirect '/' unless @user

    # Notify if the last input was invalid, then reset the flag
    @invalid_location = session[:invalid_location]
    session[:invalid_location] = false

    # Try to get user's location to populate options
    @user_location = request.location.city

    # If this isn't available default to the previous game's location
    if @user_location.to_s.empty?
      previous_game = HowFarGame.current_game(session[:uid])
      if previous_game
        @user_location = previous_game['user_location']
      end      
    end

    haml :new
  end

  post '/new' do
    redirect '/' unless @user

    location = Geocoder.search(params[:user_location])

    if location.empty?
      session[:invalid_location] = true
      redirect '/new' 
    end

    HowFarGame.new_game(session[:uid], params[:user_location])

    redirect '/play'
  end

  get '/play' do
    redirect '/' unless @user

    # Load current game
    @game = HowFarGame.current_game(session[:uid])

    redirect '/new' if @game['game_over']

    haml :play
  end

  post '/play' do
    redirect '/' unless @user

    if HowFarGame.current_game(session[:uid])['level'] != params[:level].to_i
      redirect '/play'
    end
    
    @guess = params[:distance].to_i
    @result = HowFarGame.answer_question(session[:uid], @guess)

    haml :answer
  end

  get '/leader_board' do
    @leader_board = HowFarGame.leader_board.map do |e| 

      user = @db['users'].find_one("user_id" => e['user_id'])

      {:player => user['name'], :profile_image => user['profile_image'], :level => e['level']} unless user.nil?
    end

    @game_count = @db['leader_board'].count

    haml :leader_board
  end

  get '/auth/twitter/callback' do
    halt(401,'Not Authorized') if env['omniauth.auth'].nil?
    
    session[:uid] = env['omniauth.auth']['uid']

    user = @db['users'].find_one("user_id" => session[:uid])

    if user.nil?
      new_user = {:user_id => session[:uid],
                  :name => "@" << env['omniauth.auth']['info']['nickname'],
                  :profile_image => env['omniauth.auth']['info']['image']
                }
      @db['users'].insert(new_user)
    else
      # Update with the latest pic
      user['name'] = "@" << env['omniauth.auth']['info']['nickname']
      user['profile_image'] = env['omniauth.auth']['info']['image']

      @db['users'].update({"_id" => user['_id']}, user)
    end

    redirect to("/")
  end

  get '/auth/failure' do
    params[:message]
  end

  get '/logout' do
    session[:uid] = nil
    redirect to("/")
  end
end