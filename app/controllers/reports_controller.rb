class ReportsController < ApplicationController
  before_action :authorize_reports!

  def index
  end

  def work_orders
    @from = parse_date(params[:from]) || Date.current.beginning_of_month
    @to = parse_date(params[:to]) || Date.current
    @work_orders = WorkOrder.includes(:customer, :patient)
      .where(created_at: @from.beginning_of_day..@to.end_of_day)
      .order(number: :desc)

    respond_to do |format|
      format.html
      format.csv do
        send_data work_orders_csv(@work_orders),
                  filename: "work_orders_#{@from}_#{@to}.csv",
                  type: "text/csv; charset=utf-8",
                  disposition: "attachment"
      end
    end
  end

  def payroll
    @from = parse_date(params[:from]) || Date.current.beginning_of_month
    @to = parse_date(params[:to]) || Date.current
    @lines = WorkOrderService
      .includes(:assignee, :service, work_order: :patient)
      .where(status: "completed")
      .where(completed_at: @from.beginning_of_day..@to.end_of_day)
      .joins(:assignee)
      .order("users.full_name ASC, work_order_services.completed_at ASC")

    @summaries = @lines.group_by(&:assignee_id).map do |_id, rows|
      user = rows.first.assignee
      {
        user: user,
        units: rows.sum(&:quantity),
        amount: rows.sum(&:amount),
        lines: rows
      }
    end.sort_by { |s| s[:user].full_name }
  end

  def unpaid
    @from = parse_date(params[:from])
    @to = parse_date(params[:to])
    @work_orders = WorkOrder.includes(:customer, :patient)
      .where(customer_paid_amount: 0)
      .order(number: :desc)
    @work_orders = @work_orders.where(status: params[:status]) if params[:status].present?
    if @from
      @work_orders = @work_orders.where("work_orders.created_at >= ?", @from.beginning_of_day)
    end
    if @to
      @work_orders = @work_orders.where("work_orders.created_at <= ?", @to.end_of_day)
    end
  end

  private

  def authorize_reports!
    authorize :report, "#{action_name}?"
  end

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def work_orders_csv(orders)
    rows = [ [ "Номер", "Создан", "Заказчик", "Пациент", "Статус", "Срок", "Оплата" ] ]
    orders.each do |order|
      rows << [
        order.number,
        order.created_at&.strftime("%d.%m.%Y %H:%M"),
        order.customer.name,
        order.patient&.full_name || "—",
        helpers.work_order_status_label(order.status),
        order.due_at&.strftime("%d.%m.%Y %H:%M"),
        order.customer_paid? ? order.customer_paid_amount.to_s : "нет"
      ]
    end
    SimpleCsv.generate(rows)
  end
end
