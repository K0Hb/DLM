# frozen_string_literal: true

class CustomerPaymentsController < ApplicationController
  include SafeReturnPath

  def new
    authorize :payment, :customer?
    @paid = ActiveModel::Type::Boolean.new.cast(params.fetch(:paid, true))
    @paid_at = parse_time(params[:paid_at]) || Time.current
    @note = params[:note]
    @return_to = safe_return_to(nil)
    @cancel_path = @return_to || customer_payment_orders_path
    @orders = load_orders
    if @orders.empty?
      redirect_back fallback_location: customer_payment_orders_path, alert: "Нет нарядов для оплаты."
    end
  end

  def create
    authorize :payment, :customer?
    paid = ActiveModel::Type::Boolean.new.cast(params.fetch(:paid, true))
    paid_at = parse_time(params[:paid_at]) || Time.current
    orders = load_orders_from_ids(params[:work_order_ids])
    if orders.empty?
      redirect_to after_path, alert: "Не выбраны наряды."
      return
    end
    if paid
      amounts = params[:amounts].presence || {}
      ActiveRecord::Base.transaction do
        orders.each do |order|
          amount = amounts[order.id.to_s].presence || (orders.size == 1 ? params[:amount] : nil)
          Payments::Applier.new(actor: current_user).apply_customer!(
            orders: [ order ],
            paid: true,
            paid_at: paid_at,
            note: params[:note],
            amount: amount
          )
        end
      end
    else
      Payments::Applier.new(actor: current_user).apply_customer!(
        orders: orders,
        paid: false,
        paid_at: paid_at,
        note: params[:note]
      )
    end

    redirect_to after_path, notice: paid ? "Оплата заказчиком зафиксирована." : "Отметка оплаты снята."
  rescue Payments::Error => e
    redirect_to after_path, alert: e.message
  end

  private

  def load_orders
    if params[:customer_id].present? && params[:all_unpaid].present?
      return WorkOrder.where(customer_id: params[:customer_id], customer_paid_amount: 0).includes(:customer, :patient, :work_order_services).order(:number)
    end

    ids = Array(params[:work_order_ids]).presence || Array(params[:ids])
    load_orders_from_ids(ids)
  end

  def load_orders_from_ids(ids)
    WorkOrder.where(id: ids).includes(:customer, :patient, :work_order_services).order(:number).to_a
  end

  def after_path
    safe_return_to(customer_payment_orders_path)
  end

  def parse_time(value)
    return nil if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
