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
      customer_paid_amount: 0
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
end
