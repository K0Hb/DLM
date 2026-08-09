class AddRemovedAtToWorkOrderServices < ActiveRecord::Migration[8.0]
  def change
    add_column :work_order_services, :removed_at, :datetime
    add_reference :work_order_services, :removed_by, foreign_key: { to_table: :users }
    add_index :work_order_services, :removed_at
  end
end
