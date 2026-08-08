class CreateCatalogsAndServicePool < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.string :address
      t.text :notes
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :doctors do |t|
      t.string :full_name, null: false
      t.references :customer, foreign_key: true
      t.string :phone
      t.text :notes
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :patients do |t|
      t.string :full_name, null: false
      t.text :notes
      t.timestamps
    end
    add_index :patients, :full_name

    create_table :services do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :technician_price, precision: 10, scale: 2, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :services, :name, unique: true

    create_table :services_users, id: false do |t|
      t.belongs_to :service, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
    end
    add_index :services_users, [ :service_id, :user_id ], unique: true
  end
end
