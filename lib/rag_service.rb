require_relative 'database'
require_relative 'embedding_service'

class RagService
  def initialize
    @embedding_service = EmbeddingService.new
  end

  def ask(question, product_id = nil)
    question_embedding = @embedding_service.create_embedding(question)

    relevant_reviews = find_similar_reviews(question_embedding, product_id, limit: 5)

    if relevant_reviews.empty?
      return {
        answer: "I don't have any relevant review information to answer your question.",
        sources: []
      }
    end

    context = build_context(relevant_reviews)
    prompt = build_prompt(question, context)

    answer = @embedding_service.generate_answer(prompt)

    {
      answer: answer,
      sources: relevant_reviews.map { |review| format_source(review) }
    }
  end

  private

  def find_similar_reviews(question_embedding, product_id = nil, limit: 5)
    db = Database.connection

    embedding_vector = "[#{question_embedding.join(',')}]"

    query = db[:embeddings]
      .join(:reviews, id: :review_id)
      .join(:products, id: Sequel[:reviews][:product_id])
      .select(
        Sequel[:reviews][:id].as(:review_id),
        Sequel[:reviews][:content],
        Sequel[:reviews][:rating],
        Sequel[:reviews][:author],
        Sequel[:products][:name].as(:product_name),
        Sequel.lit("vector <=> ?", embedding_vector).as(:similarity)
      )
      .order(:similarity)
      .limit(limit)

    if product_id
      query = query.where(Sequel[:products][:id] => product_id)
    end

    query.all
  end

  def build_context(reviews)
    context_parts = reviews.map do |review|
      "Product: #{review[:product_name]}\n" +
      "Rating: #{review[:rating]}/5\n" +
      "Review: #{review[:content]}\n" +
      "Author: #{review[:author]}\n"
    end

    context_parts.join("\n---\n")
  end

  def build_prompt(question, context)
    <<~PROMPT
      Based on the following product reviews, please answer the user's question.
      If the reviews don't contain relevant information to answer the question, say so.

      Reviews:
      #{context}

      Question: #{question}

      Answer:
    PROMPT
  end

  def format_source(review)
    {
      product_name: review[:product_name],
      rating: review[:rating],
      author: review[:author],
      content: review[:content][0..200] + (review[:content].length > 200 ? "..." : "")
    }
  end
end