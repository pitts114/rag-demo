require 'sinatra'
require 'sinatra/json'
require 'dotenv/load'
require_relative 'lib/database'
require_relative 'lib/embedding_service'
require_relative 'lib/rag_service'

configure do
  set :port, 4567
  set :bind, '0.0.0.0'
end

before do
  content_type :json
  # CORS headers
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
          'Access-Control-Allow-Headers' => 'Content-Type'
end

# Handle preflight requests
options '*' do
  response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  200
end

get '/' do
  json message: 'RAG Demo API - Use POST /ask to query product reviews'
end

post '/ask' do
  request_data = JSON.parse(request.body.read)

  question = request_data['question']
  product_id = request_data['product_id']

  if question.nil? || question.strip.empty?
    status 400
    return json error: 'Question is required'
  end

  begin
    rag_service = RagService.new
    result = rag_service.ask(question, product_id)

    json({
      answer: result[:answer],
      sources: result[:sources],
      product_id: product_id
    })
  rescue => e
    status 500
    json error: "Internal server error: #{e.message}"
  end
end

get '/products' do
  products = Database.products.all
  json products
end

get '/products/:id/reviews' do
  product_id = params[:id].to_i
  reviews = Database.reviews.where(product_id: product_id).all
  json reviews
end