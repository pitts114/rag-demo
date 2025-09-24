require 'httparty'
require 'json'

class EmbeddingService
  include HTTParty
  base_uri 'https://api.openai.com'

  def initialize
    @api_key = ENV['OPENAI_API_KEY']
    @embedding_model = ENV['OPENAI_EMBEDDING_MODEL'] || 'text-embedding-3-small'
    @chat_model = ENV['OPENAI_CHAT_MODEL'] || 'gpt-4o-mini'

    raise 'OPENAI_API_KEY environment variable is required' unless @api_key
  end

  def create_embedding(text)
    response = self.class.post('/v1/embeddings',
      headers: headers,
      body: {
        input: text,
        model: @embedding_model
      }.to_json
    )

    handle_response(response) do |data|
      data['data'][0]['embedding']
    end
  end

  def generate_answer(prompt)
    response = self.class.post('/v1/chat/completions',
      headers: headers,
      body: {
        model: @chat_model,
        messages: [
          {
            role: 'system',
            content: 'You are a helpful assistant that answers questions about product reviews. Base your answers only on the provided review context.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 500,
        temperature: 0.7
      }.to_json
    )

    handle_response(response) do |data|
      data['choices'][0]['message']['content']
    end
  end

  private

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@api_key}"
    }
  end

  def handle_response(response)
    if response.success?
      yield response.parsed_response
    else
      raise "OpenAI API error: #{response.code} - #{response.body}"
    end
  end
end