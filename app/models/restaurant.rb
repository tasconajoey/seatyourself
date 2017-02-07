class Restaurant < ApplicationRecord
  belongs_to :owner, class_name "User"
  has_many :reservations
  has_many :users, through: :reservations
end
