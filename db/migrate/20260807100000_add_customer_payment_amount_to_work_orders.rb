# frozen_string_literal: true

class AddCustomerPaymentAmountToWorkOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :work_orders, :customer_payment_amount, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end
