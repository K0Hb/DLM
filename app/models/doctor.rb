class Doctor < ApplicationRecord
  belongs_to :customer, optional: true
  has_many :patients, dependent: :restrict_with_exception
  has_many :work_orders, dependent: :nullify

  validates :full_name, presence: true

  def related_work_orders
    WorkOrder.where(doctor_id: id).or(WorkOrder.where(patient_id: patients.select(:id))).distinct.order(number: :desc)
  end
end
