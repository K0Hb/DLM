class DoctorsController < ApplicationController
  include CatalogCrud

  def index
    authorize Doctor
    @records = policy_scope(Doctor).includes(:customer, :patients, :work_orders).order(:full_name)
  end

  def show
    authorize @record
    @patients = @record.patients.order(:full_name)
    @work_orders = @record.related_work_orders.includes(:customer, :patient)
  end

  private

  def model_class
    Doctor
  end

  def model_label
    "Врач"
  end

  def order_column
    :full_name
  end

  def record_params
    params.require(:doctor).permit(:full_name, :customer_id, :phone, :notes, :active)
  end

  def default_attrs
    { active: true }
  end

  def after_save_path
    @record
  end
end
