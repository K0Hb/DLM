# frozen_string_literal: true

class AddCatalogPartiesP8 < ActiveRecord::Migration[8.0]
  class MigrationDoctor < ApplicationRecord
    self.table_name = "doctors"
  end

  class MigrationPatient < ApplicationRecord
    self.table_name = "patients"
  end

  def up
    add_reference :patients, :doctor, foreign_key: true

    say_with_time "backfill patients.doctor_id" do
      doctor = MigrationDoctor.order(:id).first
      doctor ||= MigrationDoctor.create!(full_name: "Врач (служебный)", active: true)
      MigrationPatient.where(doctor_id: nil).update_all(doctor_id: doctor.id)
    end

    change_column_null :patients, :doctor_id, false
    change_column_null :work_orders, :patient_id, true
  end

  def down
    change_column_null :work_orders, :patient_id, false
    remove_reference :patients, :doctor, foreign_key: true
  end
end
