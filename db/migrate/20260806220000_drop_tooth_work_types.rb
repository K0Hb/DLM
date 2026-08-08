class DropToothWorkTypes < ActiveRecord::Migration[8.0]
  def change
    drop_table :tooth_work_types, if_exists: true
  end
end
