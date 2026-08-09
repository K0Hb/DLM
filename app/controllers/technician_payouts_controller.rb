# frozen_string_literal: true

class TechnicianPayoutsController < ApplicationController
  def index
    authorize :payment, :payouts_index?
    @employees = User.employees.active_users.order(:full_name)
    scope = WorkOrderService
      .active
      .includes(:service, :assignee, work_order: %i[customer patient])
      .joins(:work_order)
      .where(technician_paid: false)
      .where.not(work_orders: { status: "draft" })
      .where.not(assignee_id: nil)
      .order("work_orders.number DESC")

    scope = scope.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    scope = scope.where(status: params[:status]) if params[:status].present?

    @total_amount = scope.sum(Arel.sql("quantity * technician_price_snapshot"))
    @lines = paginate(scope)
  end
end
