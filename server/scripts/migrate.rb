#!/usr/bin/env ruby

require 'sequel'
require 'dotenv/load'

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table! :products do
  primary_key :id
  String :name, null: false
  Text :description
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

DB.create_table! :reviews do
  primary_key :id
  foreign_key :product_id, :products, null: false
  Text :content, null: false
  Integer :rating
  String :author
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

DB.create_table! :embeddings do
  primary_key :id
  foreign_key :review_id, :reviews, null: false
  column :vector, 'vector(1536)'
  String :model_name
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

  index :review_id, unique: true
end

# Create HNSW vector index for fast cosine similarity search
DB.run("CREATE INDEX embeddings_vector_idx ON embeddings USING hnsw (vector vector_cosine_ops)")

puts "Database migration completed successfully!"