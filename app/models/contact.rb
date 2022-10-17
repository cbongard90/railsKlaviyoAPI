class Contact < ApplicationRecord
  validates :first_name, :last_name, :email, :phone_number, :date_of_birth, :country, :sms_consent, presence: true
end
