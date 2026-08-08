class Service < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :work_order_services, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :technician_price, numericality: { greater_than_or_equal_to: 0 }
end
