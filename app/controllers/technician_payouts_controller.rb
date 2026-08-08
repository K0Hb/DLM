# frozen_string_literal: true

class TechnicianPayoutsController < ApplicationController
  def index
    authorize :payment, :payouts_index?
    @employees = User.employees.active_users.order(:full_name)
    scope = WorkOrderService
      .includes(:service, :assignee, work_order: %i[customer patient])
      .joins(:work_order)
      .where(technician_paid: false)
      .where.not(work_orders: { status: "draft" })
      .where.not(assignee_id: nil)
      .order("work_orders.number DESC")

    scope = scope.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    scope = scope.where(status: params[:status]) if params[:status].present?

    @lines = scope.to_a
    @total_amount = @lines.sum(&:amount)
  end
end
