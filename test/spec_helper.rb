require 'mongo'

RSpec.configure do |config|

  db = Mongo::Connection.new("127.0.0.1", 27017).db("howfardb")

  config.before(:each) do
  	#TODO Make this work... MongoMapper/ORM?
    #Mongo::DB.stub!(:new).and_return { @db }
    Mongo::Connection.stub!(:new).and_return( nil )
    Mongo::Connection.any_instance.stub(:db).and_return( nil )
  end

  config.after(:each) do
    db.collections.each do |coll|
      coll.drop unless coll.name =~ /^system\./
    end
  end

end