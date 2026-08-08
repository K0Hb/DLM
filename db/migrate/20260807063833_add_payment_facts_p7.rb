# frozen_string_literal: true

class AddPaymentFactsP7 < ActiveRecord::Migration[8.0]
  def change
    change_table :work_order_services, bulk: true do |t|
      t.boolean :technician_paid, null: false, default: false
      t.datetime :technician_paid_at
      t.bigint :technician_paid_by_id
    end
    add_index :work_order_services, :technician_paid
    add_foreign_key :work_order_services, :users, column: :technician_paid_by_id

    add_reference :work_orders, :customer_paid_by, foreign_key: { to_table: :users }

    create_table :payment_events do |t|
      t.string :event_type, null: false
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.references :work_order, foreign_key: true
      t.references :work_order_service, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false, default: 0
      t.text :note
      t.datetime :created_at, null: false
    end
    add_index :payment_events, :event_type
    add_index :payment_events, :created_at
  end
end
