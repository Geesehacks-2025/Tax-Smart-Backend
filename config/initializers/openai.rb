require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY') { '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' }
end