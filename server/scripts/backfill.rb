#!/usr/bin/env ruby

require_relative '../lib/database'
require_relative '../lib/embedding_service'

class DataBackfill
  SAMPLE_PRODUCTS = [
    {
      name: "MacBook Pro 16-inch",
      description: "Apple's flagship laptop with M2 Pro chip, 16-inch Liquid Retina XDR display"
    },
    {
      name: "iPhone 15 Pro",
      description: "Apple's premium smartphone with A17 Pro chip and titanium design"
    },
    {
      name: "AirPods Pro (2nd generation)",
      description: "Apple's premium wireless earbuds with active noise cancellation"
    }
  ].freeze

  SAMPLE_REVIEWS = {
    1 => [
      {
        content: "The MacBook Pro is absolutely incredible! The M2 Pro chip handles everything I throw at it, from video editing to running multiple virtual machines. The battery life easily lasts me through a full workday, often 12-14 hours of coding and web browsing. The display is stunning with perfect color accuracy. Build quality feels premium and solid. Worth every penny for professional work.",
        rating: 5,
        author: "TechReviewer123"
      },
      {
        content: "Great laptop overall but there are some issues. Performance is excellent for most tasks, but it gets quite warm during intensive workloads like 3D rendering. The battery life is good, around 8-10 hours for my usage. The keyboard and trackpad are fantastic. Price is steep but justified for the performance you get.",
        rating: 4,
        author: "PowerUser2024"
      },
      {
        content: "Disappointed with the battery life on this MacBook Pro. I'm only getting about 6-7 hours with moderate usage, much less than advertised. The performance is great and the screen is beautiful, but the battery issue is a deal breaker for my mobile workflow. Considering returning it.",
        rating: 2,
        author: "NomadWorker"
      },
      {
        content: "Perfect laptop for software development. The M2 Pro handles Docker, IDEs, and compilation incredibly fast. Battery easily lasts 10+ hours during coding sessions. The additional ports are very welcome compared to older models. Screen real estate is perfect for split-screen work. Highly recommended for developers.",
        rating: 5,
        author: "DevLife"
      },
      {
        content: "The build quality and performance are excellent, but I've had some issues with the battery not holding charge as well after 6 months of use. It used to last 12+ hours, now I'm getting around 8-9 hours. Still a great machine but battery degradation seems faster than expected.",
        rating: 4,
        author: "LongTimeUser"
      }
    ],
    2 => [
      {
        content: "The iPhone 15 Pro camera system is phenomenal! The new titanium build feels premium and lighter than the steel from previous models. Battery life easily gets me through a full day of heavy usage. The Action Button is a nice touch. Face ID works flawlessly. Very happy with this upgrade from my 12 Pro.",
        rating: 5,
        author: "PhotoEnthusiast"
      },
      {
        content: "Solid phone but battery life is just okay. I get about a day with moderate usage, but heavy days require charging before evening. The camera improvements are noticeable but not groundbreaking if coming from 14 Pro. Performance is snappy as expected. Build quality is excellent.",
        rating: 4,
        author: "TechUser99"
      },
      {
        content: "Battery life has been disappointing. Coming from an iPhone 13 Pro, I expected better battery performance but I'm getting similar or slightly worse battery life. The phone is great otherwise - camera, performance, build quality are all top notch. Just wish the battery lasted longer.",
        rating: 3,
        author: "BatteryWatcher"
      },
      {
        content: "Incredible camera system and the titanium feels amazing. Battery easily lasts me 1.5 days with my usage pattern. The A17 Pro is blazingly fast. No complaints at all, this is the best iPhone I've ever owned. Worth the upgrade from my iPhone 12.",
        rating: 5,
        author: "AppleFan2023"
      }
    ],
    3 => [
      {
        content: "These AirPods Pro are a game changer! The noise cancellation is incredibly effective - perfect for flights and noisy offices. Sound quality is excellent with rich bass and clear highs. Battery life is solid, getting about 5-6 hours per charge. The spatial audio feature is immersive. Highly recommend!",
        rating: 5,
        author: "AudioPhile"
      },
      {
        content: "Good earbuds but battery life could be better. I get about 4-5 hours per charge which is adequate but not great for long days. Sound quality and noise cancellation are very good. Fit is comfortable for extended wear. The case battery life is excellent though.",
        rating: 4,
        author: "MusicLover"
      },
      {
        content: "The battery life on these is quite poor in my experience. I barely get 4 hours with noise cancellation on. Had to return my first pair due to one earbud dying quickly. Replacement pair is better but still not great battery performance. Sound quality is good when they work.",
        rating: 2,
        author: "DisappointedBuyer"
      },
      {
        content: "Amazing sound quality and the noise cancellation is perfect for my commute. Battery lasts me through my workday with some to spare. The adaptive transparency mode is brilliant for switching between isolation and awareness. Best earbuds I've owned.",
        rating: 5,
        author: "CommuterPro"
      },
      {
        content: "Great earbuds overall. Battery life is decent - I get about 5 hours per charge which works for my needs. The noise cancellation and sound quality are both excellent. Only complaint is that they occasionally disconnect from my phone, requiring a reset.",
        rating: 4,
        author: "TechReviews2024"
      }
    ]
  }.freeze

  def initialize
    @embedding_service = EmbeddingService.new
  end

  def run
    puts "Starting data backfill..."

    clear_existing_data
    create_products
    create_reviews_and_embeddings

    puts "Data backfill completed successfully!"
    puts "Created #{Database.products.count} products"
    puts "Created #{Database.reviews.count} reviews"
    puts "Created #{Database.embeddings.count} embeddings"
  end

  private

  def clear_existing_data
    puts "Clearing existing data..."
    Database.embeddings.delete
    Database.reviews.delete
    Database.products.delete
  end

  def create_products
    puts "Creating products..."
    SAMPLE_PRODUCTS.each do |product_data|
      Database.products.insert(product_data)
    end
  end

  def create_reviews_and_embeddings
    puts "Creating reviews and embeddings..."

    SAMPLE_REVIEWS.each do |product_id, reviews|
      reviews.each do |review_data|
        puts "Processing review for product #{product_id}..."

        review_id = Database.reviews.insert(
          review_data.merge(product_id: product_id)
        )

        puts "Creating embedding for review #{review_id}..."
        begin
          embedding = @embedding_service.create_embedding(review_data[:content])

          Database.embeddings.insert(
            review_id: review_id,
            vector: "[#{embedding.join(',')}]",
            model_name: ENV['OPENAI_EMBEDDING_MODEL'] || 'text-embedding-3-small'
          )

          puts "✓ Created embedding for review #{review_id}"
        rescue => e
          puts "✗ Failed to create embedding for review #{review_id}: #{e.message}"
        end

        sleep(0.1) # Small delay to avoid rate limiting
      end
    end
  end
end

if __FILE__ == $0
  backfill = DataBackfill.new
  backfill.run
end