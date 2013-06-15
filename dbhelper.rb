require 'mongo'
require 'uri'

class DbHelper
  @@db_connection = nil

	def self.get_connection
	  return @@db_connection if @@db_connection

    if ENV['MONGOHQ_URL']
      db = URI.parse(ENV['MONGOHQ_URL'])
      db_name = db.path.gsub(/^\//, '')
      @@db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
      @@db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
    else
      @@db_connection = Mongo::Connection.new("localhost", 27017).db("howfardb")
    end
	  @@db_connection
	end

  def self.set_connection (new_connection)
    @@db_connection = new_connection
  end

end