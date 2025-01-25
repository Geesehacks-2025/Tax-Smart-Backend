class UserProfile < ApplicationRecord
    # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true
  validates :address, presence: true
  validates :province, presence: true
  validates :country, presence: true
  validates :profession, presence: true
  validates :marital_status, presence: true
end
