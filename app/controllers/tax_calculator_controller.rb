class TaxCalculatorController < ApplicationController
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

        total_tax = federal_tax + provincial_tax
    
        # Send the response
        render json: {
          total_tax: total_tax,
          federal_tax: federal_tax,
          provincial_tax: provincial_tax
        }
    end
end
