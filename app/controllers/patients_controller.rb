class PatientsController < ApplicationController
  include CatalogCrud

  def index
    authorize Patient
    scope = policy_scope(Patient).includes(:doctor, :work_orders, doctor: :customer).order(:full_name)
    if params[:q].to_s.strip.present?
      scope = scope.where("patients.full_name ILIKE ?", "%#{params[:q].to_s.strip}%")
    end
    @records = paginate(scope)
  end

  def show
    authorize @record
    @work_orders = @record.work_orders.includes(:customer, :doctor).order(number: :desc)
  end

  private

  def model_class
    Patient
  end

  def model_label
    "Пациент"
  end

  def order_column
    :full_name
  end

  def record_params
    params.require(:patient).permit(:full_name, :doctor_id, :notes)
  end

  def after_save_path
    @record
  end
end
