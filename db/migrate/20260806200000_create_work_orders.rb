class CreateWorkOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :work_orders do |t|
      t.integer :number, null: false
      t.string :status, null: false, default: "draft"
      t.references :customer, null: false, foreign_key: true
      t.references :doctor, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.datetime :due_at
      t.datetime :closed_at
      t.datetime :sent_at
      t.text :notes
      t.jsonb :dental_formula, null: false, default: {}
      t.string :tooth_color
      t.string :material_note
      t.string :public_token, null: false
      t.decimal :customer_paid_amount, precision: 10, scale: 2, null: false, default: 0
      t.datetime :customer_paid_at
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :work_orders, :number, unique: true
    add_index :work_orders, :public_token, unique: true
    add_index :work_orders, :status
    add_index :work_orders, :dental_formula, using: :gin

    create_table :work_order_services do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.integer :quantity, null: false, default: 1
      t.string :status, null: false, default: "assigned"
      t.decimal :technician_price_snapshot, precision: 10, scale: 2, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.text :notes
      t.timestamps
    end

    add_index :work_order_services, :status
  end
end
