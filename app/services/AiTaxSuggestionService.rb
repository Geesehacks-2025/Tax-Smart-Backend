# app/services/ai_tax_suggestion_service.rb
class AiTaxSuggestionService
    
    
    # include HTTParty
  
    # base_uri 'https://api.openai.com/v1/chat/completions'
  
    def self.get_tax_suggestion(user_input)
        client = OpenAI::Client.new(
            access_token: "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",
            log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
        )
        response = client.chat(
            parameters: {
                model: "gpt-3.5-turbo", # Required.
                messages: [{ role: "user", content: "Hello!"}], # Required.
                temperature: 0.7,
            }
        )
    #   api_key = ENV['OPENAI_API_KEY']  # Make sure to store your API key in .env
  
    #   body = {
    #     model: 'gpt-3.5-turbo',  # Replace with 'gpt-4' or any other model you want
    #     messages: [
    #       { role: 'user', content: user_input }
    #     ],
    #     store: true  # If you need to store the conversation state, ensure this flag is valid.
    #   }.to_json
  
    #   response = post('', 
    #                   headers: {
    #                     'Content-Type' => 'application/json', 
    #                     'Authorization' => "Bearer #{api_key}"
    #                   }, 
    #                   body: body)
  
    #   # Log the response for debugging
    #   Rails.logger.info("OpenAI API Response: #{response.body}")
  
      if response.success?
        response.parsed_response['choices'][0]['message']['content']
      else
        "Sorry, there was an issue generating the suggestion. Error: #{response.body}"
      end
    end
  end
  