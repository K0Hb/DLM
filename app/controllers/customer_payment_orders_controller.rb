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

    @orders = scope.to_a
    @batch_paid = params[:paid] != "yes"
    @total_payment_amount = @orders.sum { |o| o.customer_order_payment_amount.to_d }
  end
end
