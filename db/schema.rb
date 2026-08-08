# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_08_07_100000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "email"
    t.string "address"
    t.text "notes"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "doctors", force: :cascade do |t|
    t.string "full_name", null: false
    t.bigint "customer_id"
    t.string "phone"
    t.text "notes"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_doctors_on_customer_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "full_name", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "doctor_id", null: false
    t.index ["doctor_id"], name: "index_patients_on_doctor_id"
    t.index ["full_name"], name: "index_patients_on_full_name"
  end

  create_table "payment_events", force: :cascade do |t|
    t.string "event_type", null: false
    t.bigint "actor_id", null: false
    t.bigint "work_order_id"
    t.bigint "work_order_service_id"
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.index ["actor_id"], name: "index_payment_events_on_actor_id"
    t.index ["created_at"], name: "index_payment_events_on_created_at"
    t.index ["event_type"], name: "index_payment_events_on_event_type"
    t.index ["work_order_id"], name: "index_payment_events_on_work_order_id"
    t.index ["work_order_service_id"], name: "index_payment_events_on_work_order_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "technician_price", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  create_table "services_users", id: false, force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "user_id", null: false
    t.index ["service_id", "user_id"], name: "index_services_users_on_service_id_and_user_id", unique: true
    t.index ["service_id"], name: "index_services_users_on_service_id"
    t.index ["user_id"], name: "index_services_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "role", default: "employee", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "work_order_services", force: :cascade do |t|
    t.bigint "work_order_id", null: false
    t.bigint "service_id", null: false
    t.bigint "assignee_id", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", default: "assigned", null: false
    t.decimal "technician_price_snapshot", precision: 10, scale: 2, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "technician_paid", default: false, null: false
    t.datetime "technician_paid_at"
    t.bigint "technician_paid_by_id"
    t.index ["assignee_id"], name: "index_work_order_services_on_assignee_id"
    t.index ["service_id"], name: "index_work_order_services_on_service_id"
    t.index ["status"], name: "index_work_order_services_on_status"
    t.index ["technician_paid"], name: "index_work_order_services_on_technician_paid"
    t.index ["work_order_id"], name: "index_work_order_services_on_work_order_id"
  end

  create_table "work_orders", force: :cascade do |t|
    t.integer "number", null: false
    t.string "status", default: "draft", null: false
    t.bigint "customer_id", null: false
    t.bigint "doctor_id"
    t.bigint "patient_id"
    t.datetime "due_at"
    t.datetime "closed_at"
    t.datetime "sent_at"
    t.text "notes"
    t.jsonb "dental_formula", default: {}, null: false
    t.string "tooth_color"
    t.string "material_note"
    t.string "public_token", null: false
    t.decimal "customer_paid_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "customer_paid_at"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "customer_paid_by_id"
    t.decimal "customer_payment_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["created_by_id"], name: "index_work_orders_on_created_by_id"
    t.index ["customer_id"], name: "index_work_orders_on_customer_id"
    t.index ["customer_paid_by_id"], name: "index_work_orders_on_customer_paid_by_id"
    t.index ["dental_formula"], name: "index_work_orders_on_dental_formula", using: :gin
    t.index ["doctor_id"], name: "index_work_orders_on_doctor_id"
    t.index ["number"], name: "index_work_orders_on_number", unique: true
    t.index ["patient_id"], name: "index_work_orders_on_patient_id"
    t.index ["public_token"], name: "index_work_orders_on_public_token", unique: true
    t.index ["status"], name: "index_work_orders_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "doctors", "customers"
  add_foreign_key "patients", "doctors"
  add_foreign_key "payment_events", "users", column: "actor_id"
  add_foreign_key "payment_events", "work_order_services"
  add_foreign_key "payment_events", "work_orders"
  add_foreign_key "services_users", "services"
  add_foreign_key "services_users", "users"
  add_foreign_key "work_order_services", "services"
  add_foreign_key "work_order_services", "users", column: "assignee_id"
  add_foreign_key "work_order_services", "users", column: "technician_paid_by_id"
  add_foreign_key "work_order_services", "work_orders"
  add_foreign_key "work_orders", "customers"
  add_foreign_key "work_orders", "doctors"
  add_foreign_key "work_orders", "patients"
  add_foreign_key "work_orders", "users", column: "created_by_id"
  add_foreign_key "work_orders", "users", column: "customer_paid_by_id"
end
