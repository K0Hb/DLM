require "test_helper"

class ReportsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @employee = users(:employee)
    @employee.services << services(:crown) unless @employee.services.exists?(services(:crown).id)
    @order = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      customer_paid_amount: 0,
      customer_payment_amount: 1500
    )
    @line = @order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 2
    )
  end

  test "employee cannot access reports" do
    sign_in @employee
    get reports_path
    assert_redirected_to root_path
  end

  test "admin sees work orders for period" do
    sign_in @admin
    get reports_work_orders_path, params: { from: Date.current.to_s, to: Date.current.to_s }
    assert_response :success
    assert_includes @controller.view_assigns["work_orders"].map(&:id), @order.id
  end

  test "work orders report filters by status and customer" do
    other = WorkOrder.create!(
      customer: customers(:clinic),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      status: "in_progress"
    )
    sign_in @admin
    get reports_work_orders_path, params: {
      from: Date.current.to_s,
      to: Date.current.to_s,
      status: "draft",
      customer_id: customers(:clinic).id
    }
    assert_response :success
    ids = @controller.view_assigns["work_orders"].map(&:id)
    assert_includes ids, @order.id
    assert_not_includes ids, other.id
  end

  test "admin downloads work orders csv" do
    sign_in @admin
    get reports_work_orders_path(format: :csv), params: { from: Date.current.to_s, to: Date.current.to_s }
    assert_response :success
    assert_equal "\uFEFF", response.body.b[0, 3].force_encoding("UTF-8").chars.first
    assert_includes response.body, "Номер"
    assert_includes response.body, ";"
    assert_includes response.body, @order.number.to_s
  end

  test "payroll includes completed line and excludes after rollback" do
    @line.start!(by: @admin)
    @line.complete!(by: @admin)
    sign_in @admin

    get reports_payroll_path, params: { from: Date.current.to_s, to: Date.current.to_s }
    assert_response :success
    summaries = @controller.view_assigns["summaries"]
    assert_equal 1, summaries.size
    assert_equal @line.amount, summaries.first[:amount]

    @line.rollback_to_in_progress!(by: @admin)
    get reports_payroll_path, params: { from: Date.current.to_s, to: Date.current.to_s }
    assert_empty @controller.view_assigns["summaries"]
  end

  test "payroll filters by assignee and unpaid" do
    @line.start!(by: @admin)
    @line.complete!(by: @admin)
    sign_in @admin
    get reports_payroll_path, params: {
      from: Date.current.to_s,
      to: Date.current.to_s,
      assignee_id: @employee.id,
      paid: "no"
    }
    assert_response :success
    assert_equal 1, @controller.view_assigns["summaries"].size

    get reports_payroll_path, params: {
      from: Date.current.to_s,
      to: Date.current.to_s,
      paid: "yes"
    }
    assert_empty @controller.view_assigns["summaries"]
  end

  test "unpaid report lists zero paid orders" do
    paid = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      customer_paid_amount: 100
    )
    sign_in @admin
    get reports_unpaid_path
    assert_response :success
    ids = @controller.view_assigns["work_orders"].map(&:id)
    assert_includes ids, @order.id
    assert_not_includes ids, paid.id
  end

  test "unpaid report filters by customer and positive amount" do
    zero_due = WorkOrder.create!(
      customer: customers(:clinic),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      customer_paid_amount: 0,
      customer_payment_amount: 0
    )
    sign_in @admin
    get reports_unpaid_path, params: { customer_id: customers(:clinic).id, amount: "yes" }
    assert_response :success
    ids = @controller.view_assigns["work_orders"].map(&:id)
    assert_includes ids, @order.id
    assert_not_includes ids, zero_due.id
  end

  test "admin sees funnel customers and services reports" do
    @line.start!(by: @admin)
    sign_in @admin

    get reports_funnel_path
    assert_response :success
    assert_match "Воронка", response.body
    in_hand = @controller.view_assigns["in_hand"]
    assert in_hand.any? { |user, lines| user.id == @employee.id && lines.map(&:id).include?(@line.id) }

    get reports_customers_path, params: { from: Date.current.to_s, to: Date.current.to_s }
    assert_response :success
    rows = @controller.view_assigns["rows"]
    clinic_row = rows.find { |r| r[:customer].id == customers(:clinic).id }
    assert clinic_row
    assert clinic_row[:orders_count] >= 1

    @line.complete!(by: @admin)
    get reports_services_path, params: { from: Date.current.to_s, to: Date.current.to_s }
    assert_response :success
    service_row = @controller.view_assigns["rows"].find { |r| r[:service].id == services(:crown).id }
    assert service_row
    assert_equal @line.amount, service_row[:amount]
  end
end
