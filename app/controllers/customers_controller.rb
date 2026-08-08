class CustomersController < ApplicationController
  include CatalogCrud

  def index
    authorize Customer
    @records = policy_scope(Customer).includes(:doctors, work_orders: :work_order_services).order(:name)
  end

  def show
    authorize @record
    @doctors = @record.doctors.includes(:patients).order(:full_name)
    @work_orders = @record.work_orders.includes(:patient, :doctor, :work_order_services).order(number: :desc)
    @unpaid_orders = @work_orders.reject(&:customer_paid?)
    @unpaid_total = @unpaid_orders.sum { |o| o.customer_payment_amount.to_d }
  end

  private

  def model_class
    Customer
  end

  def model_label
    "Заказчик"
  end

  def order_column
    :name
  end

  def record_params
    params.require(:customer).permit(:name, :phone, :email, :address, :notes, :active)
  end

  def default_attrs
    { active: true }
  end

  def after_save_path
    @record
  end
end
