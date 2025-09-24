# RAG Demo App

A simple Retrieval-Augmented Generation demo using Ruby/Sinatra and PostgreSQL with vector search.

## Setup

1. Copy environment variables:
   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your OpenAI API key

3. Start PostgreSQL with Docker:
   ```bash
   docker-compose up -d
   ```

4. Install dependencies:
   ```bash
   bundle install
   ```

5. Run database migrations:
   ```bash
   ruby scripts/migrate.rb
   ```

6. Backfill sample data:
   ```bash
   ruby scripts/backfill.rb
   ```

7. Start the server:
   ```bash
   bundle exec ruby app.rb
   ```

## Usage

Ask questions about product reviews:

```bash
curl -X POST http://localhost:4567/ask \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "question": "What do customers think about the battery life?"}'
```