require './test/spec_helper'
require './model/howfargame'

describe HowFarGame, "#current_game" do
  it "creates a new game" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)
    game = HowFarGame.current_game(1)
    game.should_not be_nil
  end
  it "creates a different game for each user" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)
    HowFarGame.new_game(2, "Paris", geo)
    game_1 = HowFarGame.current_game(1)
    game_2 = HowFarGame.current_game(2)
    game_1.should_not be_nil
    game_2.should_not be_nil
    game_1['user_location'].should eq("London")
    game_2['user_location'].should eq("Paris")
  end
end

describe HowFarGame, "#user_location" do
  it "is saved" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    first_loc = HowFarGame.current_game(1)['user_location']
    first_loc.should eq("London")
  end
end

describe HowFarGame, "#question_location" do
  it "is set for a new game" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    first_loc = HowFarGame.current_game(1)['question_location']
    first_loc.should_not be_nil
  end
end

describe HowFarGame, "#level" do
  it "returns 1 for a new game" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)
    game = HowFarGame.current_game(1)
    game['level'].should eq(1)
  end

  it "increments as questions are answered" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.answer_question(1, 100, geo)
    HowFarGame.current_game(1)['level'].should eq(2)

    HowFarGame.answer_question(1,   100, geo)
    HowFarGame.current_game(1)['level'].should eq(3)
  end
end

describe HowFarGame, "#points" do
  it "returns max for a new game" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)
    game = HowFarGame.current_game(1)
    game['points'].should eq(500)
  end
  it "remains the same when a questions is answered exactly" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    HowFarGame.answer_question(1, 100, geo)
    HowFarGame.current_game(1)['points'].should eq(500)

    HowFarGame.answer_question(1, 100, geo)
    HowFarGame.current_game(1)['points'].should eq(500)
  end
  it "decrements by the percentage error when a questions is not answered exactly" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    HowFarGame.answer_question(1, 80, geo)
    HowFarGame.current_game(1)['points'].should eq(480)

    HowFarGame.answer_question(1, 50, geo)
    HowFarGame.current_game(1)['points'].should eq(430)
  end
  it "doesn't decrement beyond zero" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    HowFarGame.answer_question(1, 1000, geo)
    HowFarGame.current_game(1)['points'].should eq(0)
  end
end

describe HowFarGame, "#game_over" do
  it "returns false for a new game" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)
    HowFarGame.current_game(1)['game_over'].should be_false
  end
  it "returns true when the points has reached 0" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    # Points 250
    HowFarGame.answer_question(1, 350, geo)
    HowFarGame.current_game(1)['game_over'].should be_false

    # Points 1
    HowFarGame.answer_question(1, 349, geo)
    HowFarGame.current_game(1)['game_over'].should be_false

    # Points 0
    HowFarGame.answer_question(1, 101, geo)
    HowFarGame.current_game(1)['game_over'].should be_true
  end
end

describe HowFarGame, "#leader_board" do
  it "contains game details when game completes" do
    geo = mock(Geocoder::Calculations)
    geo.stub!(:distance_between).and_return(100)

    HowFarGame.new_game(1, "London", geo)

    HowFarGame.answer_question(1, 350, geo)
    HowFarGame.answer_question(1, 349, geo)

    # End the game at level 3
    HowFarGame.answer_question(1, 101, geo)

    HowFarGame.leader_board.count.should eq(1)
  end
end