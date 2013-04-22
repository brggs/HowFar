require 'geocoder'

class HowFarGame

  def self.random_location
    places = File.open('model/places.txt').readlines
    places += File.open('model/landmarks.txt').readlines

    places[rand(places.count)]
  end

  def self.calculate_difference (place1, place2, guess)

    actual = Geocoder::Calculations.distance_between(place1, place2).round

    if guess > actual
      difference = guess - actual
    else
      difference = actual - guess
    end

    percent_diff = (difference.to_f / actual.to_f) * 100

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

    {:actual => actual, :difference => difference, :description => description}    
  end

end