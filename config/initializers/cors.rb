# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        origins 'https://t.bananotes.com/', 'http://localhost:3000' # Replace with your Next.js frontend URL
  
        resource '*', # Allow all resources
            headers: :any, # Allow all headers
            methods: [:get, :post, :put, :patch, :delete, :options, :head], # Allow listed methods
            expose: ['Authorization'], # Optional: Expose specific headers to the frontend
            max_age: 600
    end
end
  