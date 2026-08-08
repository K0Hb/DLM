# frozen_string_literal: true

class PaymentEventsController < ApplicationController
  def index
    authorize PaymentEvent
    scope = policy_scope(PaymentEvent).technician_events.includes(:actor, :work_order, work_order_service: %i[service assignee])
    scope = scope.where(event_type: params[:event_type]) if params[:event_type].present?
    if params[:assignee_id].present? && current_user.admin_or_superadmin?
      scope = scope.for_assignee(params[:assignee_id])
    end
    from = parse_date(params[:from])
    to = parse_date(params[:to])
    scope = scope.where("payment_events.created_at >= ?", from.beginning_of_day) if from
    scope = scope.where("payment_events.created_at <= ?", to.end_of_day) if to
    @events = scope.order(created_at: :desc).limit(200)
    @employees = User.employees.active_users.order(:full_name) if current_user.admin_or_superadmin?
  end

  private

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
