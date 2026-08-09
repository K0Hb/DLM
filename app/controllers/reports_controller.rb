class ReportsController < ApplicationController
  before_action :authorize_reports!

  def index
  end

  def work_orders
    @from = parse_date(params[:from]) || Date.current.beginning_of_month
    @to = parse_date(params[:to]) || Date.current
    @customers = Customer.order(:name)
    scope = filtered_work_orders_scope(@from, @to)

    respond_to do |format|
      format.html { @work_orders = paginate(scope) }
      format.csv do
        send_data work_orders_csv(scope),
                  filename: "work_orders_#{@from}_#{@to}.csv",
                  type: "text/csv; charset=utf-8",
                  disposition: "attachment"
      end
    end
  end

  def payroll
    @from = parse_date(params[:from]) || Date.current.beginning_of_month
    @to = parse_date(params[:to]) || Date.current
    @employees = User.employees.order(:full_name)
    @services = Service.order(:name)

    scope = WorkOrderService
      .includes(:assignee, :service, work_order: :patient)
      .where(status: "completed")
      .where(completed_at: @from.beginning_of_day..@to.end_of_day)
      .joins(:assignee)
      .order("users.full_name ASC, work_order_services.completed_at ASC")

    scope = scope.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    scope = scope.where(service_id: params[:service_id]) if params[:service_id].present?
    scope = scope.where(technician_paid: true) if params[:paid] == "yes"
    scope = scope.where(technician_paid: false) if params[:paid] == "no"

    @lines = scope
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
    @customers = Customer.order(:name)
    @work_orders = WorkOrder.includes(:customer, :patient)
      .where(customer_paid_amount: 0)
      .order(number: :desc)
    @work_orders = @work_orders.where(status: params[:status]) if params[:status].present?
    @work_orders = @work_orders.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    @work_orders = @work_orders.where("customer_payment_amount > 0") if params[:amount] == "yes"
    if @from
      @work_orders = @work_orders.where("work_orders.created_at >= ?", @from.beginning_of_day)
    end
    if @to
      @work_orders = @work_orders.where("work_orders.created_at <= ?", @to.end_of_day)
    end
    @work_orders = paginate(@work_orders)
  end

  def funnel
    counts = WorkOrder.group(:status).count
    @status_counts = WorkOrder::STATUSES.map { |status| [ status, counts[status].to_i ] }

    lines = WorkOrderService
      .active
      .where(status: %w[assigned in_progress])
      .includes(:assignee, :service, work_order: %i[customer patient])
      .joins(:assignee)
      .order("users.full_name ASC, work_order_services.updated_at DESC")

    @in_hand = lines.group_by(&:assignee).sort_by { |user, _| user.full_name }
  end

  def customers
    @from = parse_date(params[:from]) || Date.current.beginning_of_month
    @to = parse_date(params[:to]) || Date.current
    orders = WorkOrder.includes(:customer)
      .where(created_at: @from.beginning_of_day..@to.end_of_day)

    @rows = orders.group_by(&:customer).map do |customer, list|
      paid_sum = list.sum { |o| o.customer_paid_amount.to_d }
      debt_sum = list.reject(&:customer_paid?).sum { |o| o.customer_payment_amount.to_d }
      {
        customer: customer,
        orders_count: list.size,
        paid_sum: paid_sum,
        debt_sum: debt_sum,
        due_sum: paid_sum + debt_sum
      }
    end.sort_by { |row| row[:customer].name }

    @rows = paginate_array(@rows)
  end

  def services
    @from = parse_date(params[:from]) || Date.current.beginning_of_month
    @to = parse_date(params[:to]) || Date.current
    lines = WorkOrderService
      .includes(:service)
      .where(status: "completed")
      .where(completed_at: @from.beginning_of_day..@to.end_of_day)

    @rows = lines.group_by(&:service).map do |service, list|
      {
        service: service,
        quantity: list.sum(&:quantity),
        amount: list.sum(&:amount),
        lines_count: list.size
      }
    end.sort_by { |row| -row[:amount] }

    @rows = paginate_array(@rows)
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

  def filtered_work_orders_scope(from, to)
    scope = WorkOrder.includes(:customer, :patient)
      .where(created_at: from.beginning_of_day..to.end_of_day)
      .order(number: :desc)
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    if params[:paid] == "yes"
      scope = scope.where("customer_paid_amount > 0")
    elsif params[:paid] == "no"
      scope = scope.where(customer_paid_amount: 0)
    end
    scope
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

  def paginate_array(array, per_page: Pagination::DEFAULT_PER_PAGE)
    page = params[:page].to_i
    page = 1 if page < 1
    total_count = array.size
    total_pages = [ (total_count.to_f / per_page).ceil, 1 ].max
    page = total_pages if page > total_pages
    offset = (page - 1) * per_page
    slice = array.slice(offset, per_page) || []
    @pagination = Pagination.new(
      records: slice,
      page: page,
      per_page: per_page,
      total_count: total_count
    )
    slice
  end
end
