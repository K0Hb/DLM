class Customer < ApplicationRecord
  has_many :doctors, dependent: :nullify
  has_many :work_orders, dependent: :restrict_with_exception

  validates :name, presence: true
end
