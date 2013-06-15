require './dbhelper'
require 'mongo'

RSpec.configure do |config|

  db = Mongo::Connection.new("127.0.0.1", 27017).db("howfardb_test")

  config.before(:each) do
    DbHelper.set_connection db
  end

  config.after(:each) do

    DbHelper.get_connection.should eq(db)

    db.collections.each do |coll|
      coll.drop unless coll.name =~ /^system\./
    end
  end

end