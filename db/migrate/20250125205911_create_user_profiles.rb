class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :address
      t.string :marital_status
      t.decimal :spouse_net_income

      t.timestamps
    end
  end
end
