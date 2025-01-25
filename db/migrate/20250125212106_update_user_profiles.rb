class UpdateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    change_table :user_profiles do |t|
      # Add new fields
      t.string :phone_number
      t.string :province
      t.string :country
      t.string :profession

      # Remove old fields
      t.remove :phone
      t.remove :spouse_net_income
    end
  end
end