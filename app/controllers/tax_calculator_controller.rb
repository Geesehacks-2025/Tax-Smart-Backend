class TaxCalculatorController < ApplicationController
    skip_forgery_protection
    def initialize
        # @client = OpenAI::Client.new
        @client = Anthropic::Client.new(access_token: "   ")
    end
    
    def askquestion(question)
        # response = @client.chat(
        #     parameters: {
        #     model: 'gpt-3.5-turbo', # You can use 'gpt-3.5-turbo' for GPT-3.5
        #     messages: [{ role: 'user', content: question }],
        #     temperature: 0.7
        #     }
        # )
        # response.dig('choices', 0, 'message', 'content').strip
        # rescue StandardError => e
        #     Rails.logger.error("OpenAI API error: #{e.message}")
        #     'Sorry, I am having trouble responding at the moment.'
        begin
            response = @client.messages(
                parameters: {
                    model: "claude-3-haiku-20240307", # claude model
                    system: "Respond only in Spanish.",
                    messages: [
                        {"role": "user", "content": "Hello, Claude! " + question + " Answer in the provided JSON format. Only include JSON."},
                        { role: "assistant", content: '[{"name": "Mountain Name", "height": "height in km"}]' }
                    ],
                    max_tokens: 1000
                }
            )
            # Parse the response content
            response_content = response.dig('choices', 0, 'message', 'content').strip
            return response_content
        rescue StandardError => e
            Rails.logger.error("Claude API error: #{e.message}")
            return 'Sorry, I am having trouble responding at the moment.'
        end
    end
    def calculate
        required_params = [:employment_income, :rrsp_fhsa_deductions, :capital_gains, :dividend_income, :other_income]
        missing_params = required_params.select { |param| params[param].blank? }

        if missing_params.any?
            render json: { error: "Missing parameters: #{missing_params.join(', ')}" }, status: :bad_request
            return
        end
        # Extract values from the request body
        employment_income = params[:employment_income].to_f
        rrsp_fhsa_deductions = params[:rrsp_fhsa_deductions].to_f
        capital_gains = params[:capital_gains].to_f
        dividend_income = params[:dividend_income].to_f
        other_income = params[:other_income].to_f
        province = params[:province]
    
        # Calculate total income (example calculation)
        total_income = employment_income + capital_gains / 2 + dividend_income * 0.15 + other_income
    
        # Apply deductions (example)
        total_income_after_deductions = total_income - rrsp_fhsa_deductions

        federal_tax = 0
        provincial_tax = 0

        if total_income_after_deductions <= 57375
            federal_tax = total_income_after_deductions * 0.15
        elsif total_income_after_deductions <= 114750
            federal_tax = 57375 * 0.15 + (total_income_after_deductions - 57375) * 0.205
        elsif total_income_after_deductions <= 177882
            federal_tax = 57375 * 0.15 + (114750 - 57375) * 0.205 + (total_income_after_deductions - 114750) * 0.26
        elsif total_income_after_deductions <= 253414
            federal_tax = 57375 * 0.15 + (114750 - 57375) * 0.205 + (177882 - 114750) * 0.26 + (total_income_after_deductions - 177882) * 0.29
        else
            federal_tax = 57375 * 0.15 + (114750 - 57375) * 0.205 + (177882 - 114750) * 0.26 + (253414 - 177882) * 0.29 + (total_income_after_deductions - 253414) * 0.33
        end
        
        if province 
            case province
                when "British Columbia"
                    # British Columbia tax brackets for 2025
                    if total_income_after_deductions <= 49279
                        provincial_tax = total_income_after_deductions * 0.0506
                    elsif total_income_after_deductions <= 98560
                        provincial_tax = 49279 * 0.0506 + (total_income_after_deductions - 49279) * 0.077
                    elsif total_income_after_deductions <= 113158
                        provincial_tax = 49279 * 0.0506 + (98560 - 49279) * 0.077 + (total_income_after_deductions - 98560) * 0.105
                    elsif total_income_after_deductions <= 137407
                        provincial_tax = 49279 * 0.0506 + (98560 - 49279) * 0.077 + (113158 - 98560) * 0.105 + (total_income_after_deductions - 113158) * 0.1229
                    elsif total_income_after_deductions <= 186306
                        provincial_tax = 49279 * 0.0506 + (98560 - 49279) * 0.077 + (113158 - 98560) * 0.105 + (137407 - 113158) * 0.1229 + (total_income_after_deductions - 137407) * 0.147
                    elsif total_income_after_deductions <= 259829
                        provincial_tax = 49279 * 0.0506 + (98560 - 49279) * 0.077 + (113158 - 98560) * 0.105 + (137407 - 113158) * 0.1229 + (186306 - 137407) * 0.147 + (total_income_after_deductions - 186306) * 0.168
                    else
                        provincial_tax = 49279 * 0.0506 + (98560 - 49279) * 0.077 + (113158 - 98560) * 0.105 + (137407 - 113158) * 0.1229 + (186306 - 137407) * 0.147 + (259829 - 186306) * 0.168 + (total_income_after_deductions - 259829) * 0.205
                    end

                when "Quebec"
                    # Quebec tax brackets for 2025
                    if total_income_after_deductions <= 53255
                        provincial_tax = total_income_after_deductions * 0.14
                    elsif total_income_after_deductions <= 106495
                        provincial_tax = 53255 * 0.14 + (total_income_after_deductions - 53255) * 0.19
                    elsif total_income_after_deductions <= 129590
                        provincial_tax = 53255 * 0.14 + (106495 - 53255) * 0.19 + (total_income_after_deductions - 106495) * 0.24
                    else
                        provincial_tax = 53255 * 0.14 + (106495 - 53255) * 0.19 + (129590 - 106495) * 0.24 + (total_income_after_deductions - 129590) * 0.2575
                    end

                else
                    if total_income_after_deductions <= 52886
                        provincial_tax = total_income_after_deductions * 0.0505
                    elsif total_income_after_deductions <= 105775
                        provincial_tax = 52886 * 0.0505 + (total_income_after_deductions - 52886) * 0.0915
                    elsif total_income_after_deductions <= 150000
                        provincial_tax = 52886 * 0.0505 + (105775 - 52886) * 0.0915 + (total_income_after_deductions - 105775) * 0.1116
                    elsif total_income_after_deductions <= 220000
                        provincial_tax = 52886 * 0.0505 + (105775 - 52886) * 0.0915 + (150000 - 105775) * 0.1116 + (total_income_after_deductions - 150000) * 0.1216
                    else
                        provincial_tax = 52886 * 0.0505 + (105775 - 52886) * 0.0915 + (150000 - 105775) * 0.1116 + (220000 - 150000) * 0.1216 + (total_income_after_deductions - 220000) * 0.1316
                    end
            end  
        else
            # default to ontario
            if total_income_after_deductions <= 52886
                provincial_tax = total_income_after_deductions * 0.0505
            elsif total_income_after_deductions <= 105775
                provincial_tax = 52886 * 0.0505 + (total_income_after_deductions - 52886) * 0.0915
            elsif total_income_after_deductions <= 150000
                provincial_tax = 52886 * 0.0505 + (105775 - 52886) * 0.0915 + (total_income_after_deductions - 105775) * 0.1116
            elsif total_income_after_deductions <= 220000
                provincial_tax = 52886 * 0.0505 + (105775 - 52886) * 0.0915 + (150000 - 105775) * 0.1116 + (total_income_after_deductions - 150000) * 0.1216
            else
                provincial_tax = 52886 * 0.0505 + (105775 - 52886) * 0.0915 + (150000 - 105775) * 0.1116 + (220000 - 150000) * 0.1216 + (total_income_after_deductions - 220000) * 0.1316
            end
        end

        federal_tax = [0, federal_tax].max
        provincial_tax = [0, provincial_tax].max
        total_tax = federal_tax + provincial_tax
        # ai_response = AiTaxSuggestionService.get_tax_suggestion(params)
        # params_as_string = format_params_for_chatbot(params)
        # ai_response = self.askquestion(params_as_string)
    
        # Send the response
        render json: {
          total_tax: total_tax,
          federal_tax: federal_tax,
          provincial_tax: provincial_tax
        #   ai_response: ai_response
        }
    end
    def format_params_for_chatbot(params)
        # Create a more readable string for the chatbot
        formatted_string = "Tax information: "
        formatted_string += "Employment income: #{params[:employment_income]}, "
        formatted_string += "RRSP/FHSA deductions: #{params[:rrsp_fhsa_deductions]}, "
        formatted_string += "Capital gains: #{params[:capital_gains]}, "
        formatted_string += "Dividend income: #{params[:dividend_income]}, "
        formatted_string += "Other income: #{params[:other_income]}"
        formatted_string += "help give some tax advice(less than 50 words)"
        formatted_string
    end
end
