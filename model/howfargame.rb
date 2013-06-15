require './dbhelper'
require 'geocoder'

class HowFarGame
  def self.new_game (user_id, user_location, geo = Geocoder::Calculations)
    @db = DbHelper.get_connection

    games = @db['games']
    games.remove("user_id" => user_id)

    next_question = next_location(user_location, geo)

    new_game = {:user_id => user_id,
                :level => 1,
                :points => 500,
                :user_location => user_location,
                :question_location => next_question[:question_location],
                :distance => next_question[:distance]}
    games.insert(new_game)
  end  

  def self.current_game (user_id)
    @db = DbHelper.get_connection
    games = @db['games']
    games.find_one("user_id" => user_id)
  end  

  def self.answer_question (user_id, guess, geo = Geocoder::Calculations)
    @db = DbHelper.get_connection
    game = current_game(user_id)

    # Deal with answer
    actual = game['distance']

    if guess > actual
      difference = guess - actual
    else
      difference = actual - guess
    end

    percent_diff = ((difference.to_f / actual.to_f) * 100).round  

    if percent_diff < 1
      description = "Nicely Googled!"
    elsif percent_diff < 10
      description = "Awesome!"
    elsif percent_diff < 30
      description = "Not bad!"
    elsif percent_diff < 50
      description = "Ok..."
    elsif percent_diff < 75
      description = "Maybe time to buy a globe?"
    elsif percent_diff < 100
      description = "My Gran can do better than that!"
    else
      description = "Are you drunk?"
    end

    game['points'] -= percent_diff

    results = { :level => game['level'],
                :user_location => game['user_location'],
                :question_location => game['question_location'],
                :actual => actual, 
                :difference => difference, 
                :percent_diff => percent_diff, 
                :description => description}

    if game['points'] > 0
      # Set up next question
      next_question = next_location(game['user_location'], geo)
      game['level'] += 1
      game['question_location'] = next_question[:question_location]
      game['distance'] = next_question[:distance]
    else
      # Game over!
      game['points'] = 0
      game['game_over'] = true
      results[:game_over] = true

      #TODO Make this a capped collection
      @db['leader_board'].insert ({:user_id => user_id, :level => game['level']})
    end

    results[:points] = game['points']
    
    @db['games'].update({"_id" => game['_id']}, game)

    # Return answer details
    results
  end

  def self.leader_board
    @db = DbHelper.get_connection
    @db['leader_board'].find.sort(:level => :desc).limit(10)
  end  

end

def next_location (user_location, geo = Geocoder::Calculations)
  @db = DbHelper.get_connection
  places = File.open('model/places.txt').readlines
  places += File.open('model/landmarks.txt').readlines

  begin
    question_location = places[rand(places.count)]

    # Check that the distance is not < 50 miles
    distance = geo.distance_between(user_location, question_location).round

  end while distance < 50

  {:question_location => question_location, :distance => distance}
end