class Patient < ApplicationRecord
  belongs_to :doctor
  has_many :work_orders, dependent: :restrict_with_exception

  validates :full_name, presence: true

  def customer
    doctor&.customer
  end
end
