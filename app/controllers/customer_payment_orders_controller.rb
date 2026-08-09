# frozen_string_literal: true

class CustomerPaymentOrdersController < ApplicationController
  def index
    authorize :payment, :customer?
    @customers = Customer.where(active: true).order(:name)
    scope = WorkOrder.includes(:customer, :patient, :work_order_services).order(number: :desc)

    scope = scope.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    scope = scope.where(status: params[:status]) if params[:status].present?

    case params[:paid]
    when "yes"
      scope = scope.where("customer_paid_amount > 0")
    when "no"
      scope = scope.where(customer_paid_amount: 0)
    end

    totals = scope.except(:includes, :preload, :eager_load, :order).pick(
      Arel.sql("COUNT(*)"),
      Arel.sql("COALESCE(SUM(CASE WHEN customer_paid_amount > 0 THEN customer_paid_amount ELSE customer_payment_amount END), 0)")
    )
    @total_count = totals&.first.to_i
    @total_payment_amount = totals&.second.to_d
    @orders = paginate(scope)
    @batch_paid = params[:paid] != "yes"
  end
end
