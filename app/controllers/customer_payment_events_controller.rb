# frozen_string_literal: true

class CustomerPaymentEventsController < ApplicationController
  def index
    authorize :payment, :customer?
    scope = PaymentEvent.customer_events.includes(:actor, work_order: :customer)
    scope = scope.where(event_type: params[:event_type]) if params[:event_type].present?
    if params[:customer_id].present?
      scope = scope.joins(:work_order).where(work_orders: { customer_id: params[:customer_id] })
    end
    from = parse_date(params[:from])
    to = parse_date(params[:to])
    scope = scope.where("payment_events.created_at >= ?", from.beginning_of_day) if from
    scope = scope.where("payment_events.created_at <= ?", to.end_of_day) if to
    @events = paginate(scope.order(created_at: :desc))
    @customers = Customer.where(active: true).order(:name)
  end

  private

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
