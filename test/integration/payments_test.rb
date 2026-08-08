# frozen_string_literal: true

require "test_helper"

class PaymentsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @superadmin = users(:superadmin)
    @employee = users(:employee)
    @employee.services << services(:crown) unless @employee.services.exists?(services(:crown).id)
    @order = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      status: "in_progress"
    )
    @line = @order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 2
    )
  end

  test "employee confirms own technician payout and journal event" do
    sign_in @employee
    get new_technician_payment_path(work_order_service_ids: [ @line.id ], paid: true)
    assert_response :success

    assert_difference -> { PaymentEvent.count }, 1 do
      post technician_payment_path, params: {
        paid: true,
        work_order_service_ids: [ @line.id ],
        paid_at: Time.current.strftime("%Y-%m-%dT%H:%M"),
        return_to: my_task_path(@line)
      }
    end

    assert @line.reload.technician_paid?
    assert_equal @employee.id, @line.technician_paid_by_id
    event = PaymentEvent.order(:created_at).last
    assert_equal "technician_paid", event.event_type
    assert_equal @employee.id, event.actor_id
    assert_equal @line.amount, event.amount
  end

  test "employee cannot payout foreign line" do
    other = User.create!(
      email: "pay-other@example.com",
      password: "password123",
      password_confirmation: "password123",
      full_name: "Pay Other",
      role: "employee",
      active: true
    )
    other.services << services(:crown)
    foreign = @order.work_order_services.create!(
      service: services(:crown),
      assignee: other,
      quantity: 1
    )

    sign_in @employee
    post technician_payment_path, params: {
      paid: true,
      work_order_service_ids: [ foreign.id ]
    }
    assert_not foreign.reload.technician_paid?
  end

  test "draft work order line is not payable" do
    draft = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      status: "draft"
    )
    line = draft.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )

    sign_in @employee
    get new_technician_payment_path(work_order_service_ids: [ line.id ], paid: true)
    assert_redirected_to my_tasks_path
    assert_not line.reload.technician_paid?
  end

  test "admin marks customer paid for one order via confirmation" do
    @order.update!(customer_payment_amount: 1500)
    sign_in @admin
    get new_customer_payment_path(work_order_ids: [ @order.id ], paid: true)
    assert_response :success
    assert_select "input[name=?][value=?]", "amounts[#{@order.id}]", "1500.0"

    assert_difference -> { PaymentEvent.count }, 1 do
      post customer_payment_path, params: {
        paid: true,
        work_order_ids: [ @order.id ],
        amount: 1500,
        paid_at: Time.current.strftime("%Y-%m-%dT%H:%M"),
        return_to: work_order_path(@order)
      }
    end

    assert @order.reload.customer_paid?
    assert_equal 1500, @order.customer_paid_amount
    assert_equal @admin.id, @order.customer_paid_by_id
    assert_equal "customer_paid", PaymentEvent.order(:created_at).last.event_type
  end

  test "admin pays all unpaid orders for a customer" do
    second = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      status: "in_progress"
    )
    second.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )

    sign_in @admin
    assert_difference -> { PaymentEvent.where(event_type: "customer_paid").count }, 2 do
      post customer_payment_path, params: {
        paid: true,
        work_order_ids: [ @order.id, second.id ],
        amounts: { @order.id => 5000, second.id => 3000 },
        paid_at: Time.current.strftime("%Y-%m-%dT%H:%M")
      }
    end

    assert @order.reload.customer_paid?
    assert_equal 5000, @order.customer_paid_amount
    assert second.reload.customer_paid?
    assert_equal 3000, second.customer_paid_amount
  end

  test "employee cannot mark customer payment" do
    sign_in @employee
    post customer_payment_path, params: {
      paid: true,
      work_order_ids: [ @order.id ],
      amount: 100
    }
    assert_redirected_to root_path
    assert_not @order.reload.customer_paid?
  end

  test "technician payout locked after 30 days for employee and admin but not superadmin" do
    @line.update!(
      technician_paid: true,
      technician_paid_at: 31.days.ago,
      technician_paid_by: @admin
    )

    sign_in @employee
    post technician_payment_path, params: {
      paid: false,
      work_order_service_ids: [ @line.id ]
    }
    assert @line.reload.technician_paid?

    sign_in @admin
    post technician_payment_path, params: {
      paid: false,
      work_order_service_ids: [ @line.id ]
    }
    assert @line.reload.technician_paid?

    sign_in @superadmin
    assert_difference -> { PaymentEvent.where(event_type: "technician_unpaid").count }, 1 do
      post technician_payment_path, params: {
        paid: false,
        work_order_service_ids: [ @line.id ]
      }
    end
    assert_not @line.reload.technician_paid?
  end

  test "my_earnings redirects to merged my_tasks tab" do
    sign_in @employee
    get my_earnings_path
    assert_redirected_to my_tasks_path(tab: "earnings")
    follow_redirect!
    assert_response :success
    assert_match "Начисления и оплаты", response.body
  end

  test "admin customer payment journal lists customer events only" do
    Payments::Applier.new(actor: @admin).apply_technician!(lines: [ @line ], paid: true)
    Payments::Applier.new(actor: @admin).apply_customer!(
      orders: [ @order ],
      paid: true,
      amount: 2000
    )

    sign_in @admin
    get customer_payment_events_path
    assert_response :success
    assert_equal 1, @controller.view_assigns["events"].size
    assert_equal "customer_paid", @controller.view_assigns["events"].first.event_type

    get payment_events_path
    assert_response :success
    @controller.view_assigns["events"].each do |event|
      assert event.technician_event?
    end
  end

  test "employee cannot access customer payment journal" do
    sign_in @employee
    get customer_payment_events_path
    assert_redirected_to root_path
  end

  test "employee sees own journal and earnings; admin sees all" do
    Payments::Applier.new(actor: @employee).apply_technician!(lines: [ @line ], paid: true)

    sign_in @employee
    get payment_events_path
    assert_response :success
    assert_equal 1, @controller.view_assigns["events"].size

    get my_earnings_path
    assert_redirected_to my_tasks_path(tab: "earnings")
    follow_redirect!
    assert_response :success
    assert_includes @controller.view_assigns["lines"].map(&:id), @line.id

    other = User.create!(
      email: "journal-other@example.com",
      password: "password123",
      password_confirmation: "password123",
      full_name: "Journal Other",
      role: "employee",
      active: true
    )
    other.services << services(:crown)
    other_line = @order.work_order_services.create!(
      service: services(:crown),
      assignee: other,
      quantity: 1
    )
    Payments::Applier.new(actor: @admin).apply_technician!(lines: [ other_line ], paid: true)

    sign_in @admin
    get payment_events_path
    assert_response :success
    assert_operator @controller.view_assigns["events"].size, :>=, 2
  end

  test "admin customer payment orders index lists unpaid orders" do
    @order.update!(customer_payment_amount: 4200)
    sign_in @admin
    get customer_payment_orders_path
    assert_response :success
    assert_includes @controller.view_assigns["orders"].map(&:id), @order.id
    assert_select "input[type=checkbox][name='work_order_ids[]']"
    assert_select "a", text: "Открыть"
    assert_match(/4[\s\u00a0]?200/, response.body)
  end

  test "admin batch marks customer paid from payment orders flow" do
    second = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty,
      status: "in_progress"
    )
    second.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )

    sign_in @admin
    post customer_payment_path, params: {
      paid: true,
      work_order_ids: [ @order.id, second.id ],
      amounts: { @order.id => 5000, second.id => 3000 }
    }
    assert @order.reload.customer_paid?
    assert_equal 5000, @order.customer_paid_amount
    assert second.reload.customer_paid?
    assert_equal 3000, second.customer_paid_amount
  end

  test "employee cannot access customer payment orders index" do
    sign_in @employee
    get customer_payment_orders_path
    assert_redirected_to root_path
  end

  test "admin payouts index lists unpaid payable lines" do
    sign_in @admin
    get technician_payouts_path
    assert_response :success
    assert_includes @controller.view_assigns["lines"].map(&:id), @line.id
    assert_select "input[type=checkbox][name='work_order_service_ids[]']"
  end

  test "employee cannot access admin payouts index" do
    sign_in @employee
    get technician_payouts_path
    assert_redirected_to root_path
  end

  test "admin batch pays assignee unpaid lines" do
    second = @order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )

    sign_in @admin
    get new_technician_payment_path(assignee_id: @employee.id, paid: true)
    assert_response :success
    assert_includes @controller.view_assigns["lines"].map(&:id), @line.id
    assert_includes @controller.view_assigns["lines"].map(&:id), second.id
    assert_select "input[type=checkbox][name='work_order_service_ids[]']", minimum: 2

    post technician_payment_path, params: {
      paid: true,
      work_order_service_ids: [ @line.id, second.id ]
    }
    assert @line.reload.technician_paid?
    assert second.reload.technician_paid?
  end

  test "admin can exclude line from batch via unchecked checkbox" do
    second = @order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )

    sign_in @admin
    post technician_payment_path, params: {
      paid: true,
      work_order_service_ids: [ @line.id ]
    }
    assert @line.reload.technician_paid?
    assert_not second.reload.technician_paid?
  end
end
