require 'sequel'
require 'dotenv/load'

class Database
  def self.connection
    @connection ||= Sequel.connect(ENV['DATABASE_URL'])
  end

  def self.products
    connection[:products]
  end

  def self.reviews
    connection[:reviews]
  end

  def self.embeddings
    connection[:embeddings]
  end
end