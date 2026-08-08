# frozen_string_literal: true

class PaymentEvent < ApplicationRecord
  self.record_timestamps = false

  EVENT_TYPES = %w[
    technician_paid
    technician_unpaid
    customer_paid
    customer_unpaid
  ].freeze

  belongs_to :actor, class_name: "User"
  belongs_to :work_order, optional: true
  belongs_to :work_order_service, optional: true

  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  scope :technician_events, -> { where(event_type: %w[technician_paid technician_unpaid]) }
  scope :customer_events, -> { where(event_type: %w[customer_paid customer_unpaid]) }
  scope :for_assignee, ->(user_id) {
    joins(:work_order_service).where(work_order_services: { assignee_id: user_id })
  }

  def technician_event?
    event_type.start_with?("technician_")
  end

  def label
    {
      "technician_paid" => "Оплачено сотруднику",
      "technician_unpaid" => "Снята оплата сотруднику",
      "customer_paid" => "Оплачен заказчиком",
      "customer_unpaid" => "Снята оплата заказчиком"
    }[event_type]
  end
end
