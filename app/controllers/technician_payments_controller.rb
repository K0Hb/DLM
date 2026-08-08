# frozen_string_literal: true

class TechnicianPaymentsController < ApplicationController
  include SafeReturnPath

  def new
    authorize :payment, :technician?
    @paid = ActiveModel::Type::Boolean.new.cast(params.fetch(:paid, true))
    @paid_at = parse_time(params[:paid_at]) || Time.current
    @note = params[:note]
    @return_to = safe_return_to(nil)
    @cancel_path = @return_to || default_fallback
    @lines = load_lines
    if @lines.empty?
      redirect_back fallback_location: default_fallback, alert: "Нет подходящих услуг для оплаты сотруднику."
    end
  end

  def create
    authorize :payment, :technician?
    paid = ActiveModel::Type::Boolean.new.cast(params.fetch(:paid, true))
    paid_at = parse_time(params[:paid_at]) || Time.current
    lines = load_lines_from_ids(params[:work_order_service_ids])
    if lines.empty?
      redirect_to after_path, alert: "Не выбраны услуги."
      return
    end

    Payments::Applier.new(actor: current_user).apply_technician!(
      lines: lines,
      paid: paid,
      paid_at: paid_at,
      note: params[:note]
    )
    redirect_to after_path, notice: paid ? "Оплата сотруднику зафиксирована." : "Отметка оплаты снята."
  rescue Payments::Error => e
    redirect_to after_path, alert: e.message
  end

  private

  def default_fallback
    current_user.admin_or_superadmin? ? technician_payouts_path : my_tasks_path
  end

  def load_lines
    ids = Array(params[:work_order_service_ids]).presence || Array(params[:ids])
    if ids.present?
      return load_lines_from_ids(ids)
    end

    if params[:assignee_id].present? && current_user.admin_or_superadmin?
      scope = WorkOrderService.includes(:work_order, :service, :assignee)
        .where(assignee_id: params[:assignee_id], technician_paid: false)
      return scope.select { |l| Payments::Applier.technician_payable?(l) }
    end

    []
  end

  def load_lines_from_ids(ids)
    scope = policy_scope(WorkOrderService).includes(:work_order, :service, :assignee).where(id: ids)
    scope.select { |l| Payments::Applier.technician_payable?(l) }
  end

  def after_path
    safe_return_to(default_fallback)
  end

  def parse_time(value)
    return nil if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
