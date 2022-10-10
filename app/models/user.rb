class User < ApplicationRecord
  validates :first_name, :last_name, :email, :phone_number, presence: true
end
