require "test_helper"

class WorkOrdersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @employee = users(:employee)
    @employee.services << services(:crown) unless @employee.services.exists?(services(:crown).id)
    sign_in @admin
  end

  test "admin creates work order with patient" do
    assert_difference("WorkOrder.count", 1) do
      post work_orders_path, params: {
        work_order: {
          customer_id: customers(:clinic).id,
          patient_id: patients(:anna).id,
          doctor_id: doctors(:without_customer).id,
          dental_formula: { notation: "fdi", shade: "A2", teeth: [ { n: 14, type: "crown" } ], connectors: [] }.to_json
        }
      }
    end
    order = WorkOrder.order(:id).last
    assert_equal "draft", order.status
    assert order.number >= 1
    assert_equal 14, order.dental_formula["teeth"].first["n"]
    assert_redirected_to work_order_path(order)
  end

  test "admin creates work order with inline patient and doctor" do
    assert_difference([ "WorkOrder.count", "Patient.count" ], 1) do
      post work_orders_path, params: {
        new_patient_full_name: "Новый Пациент Тестов",
        work_order: {
          customer_id: customers(:clinic).id,
          patient_id: "",
          doctor_id: doctors(:ivanov).id,
          dental_formula: Odontogram.empty.to_json
        }
      }
    end
    order = WorkOrder.order(:id).last
    assert_equal "Новый Пациент Тестов", order.patient.full_name
    assert_equal doctors(:ivanov).id, order.patient.doctor_id
  end

  test "admin creates customer-only work order without patient" do
    assert_difference("WorkOrder.count", 1) do
      post work_orders_path, params: {
        work_order: {
          customer_id: customers(:clinic).id,
          patient_id: "",
          doctor_id: "",
          dental_formula: Odontogram.empty.to_json
        }
      }
    end
    order = WorkOrder.order(:id).last
    assert_nil order.patient_id
    assert_nil order.doctor_id
  end

  test "inline patient without doctor is rejected" do
    assert_no_difference([ "WorkOrder.count", "Patient.count" ]) do
      post work_orders_path, params: {
        new_patient_full_name: "Сирота",
        work_order: {
          customer_id: customers(:clinic).id,
          patient_id: "",
          doctor_id: "",
          dental_formula: Odontogram.empty.to_json
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "odontogram accepts configured tooth type with per-tooth material" do
    order = create_order
    patch work_order_path(order), params: {
      work_order: {
        customer_id: order.customer_id,
        patient_id: order.patient_id,
        tooth_color: "A3",
        dental_formula: {
          notation: "fdi",
          shade: "A3",
          teeth: [ { n: 21, type: "veneer", material: "emax" } ],
          connectors: []
        }.to_json
      }
    }
    order.reload
    tooth = order.dental_formula["teeth"].first
    assert_equal "veneer", tooth["type"]
    assert_equal "emax", tooth["material"]
    assert_equal "A3", order.dental_formula["shade"]
    assert_equal "A3", order.tooth_color
  end

  test "odontogram rejects unknown shade code" do
    order = create_order
    patch work_order_path(order), params: {
      work_order: {
        customer_id: order.customer_id,
        patient_id: order.patient_id,
        dental_formula: {
          notation: "fdi",
          shade: "NOT_A_SHADE",
          teeth: [ { n: 11, type: "healthy", material: nil } ],
          connectors: []
        }.to_json
      }
    }
    order.reload
    assert_nil order.dental_formula["shade"]
    assert_equal "healthy", order.dental_formula["teeth"].first["type"]
  end

  test "odontogram rejects unknown material code" do
    order = create_order
    patch work_order_path(order), params: {
      work_order: {
        customer_id: order.customer_id,
        patient_id: order.patient_id,
        dental_formula: {
          notation: "fdi",
          shade: "A2",
          teeth: [ { n: 21, type: "veneer", material: "not_a_real_material" } ],
          connectors: []
        }.to_json
      }
    }
    order.reload
    tooth = order.dental_formula["teeth"].first
    assert_equal 21, tooth["n"]
    assert_equal "veneer", tooth["type"]
    assert_nil tooth["material"]
  end

  test "odontogram allows selected tooth with null type and material" do
    order = create_order
    patch work_order_path(order), params: {
      work_order: {
        customer_id: order.customer_id,
        patient_id: order.patient_id,
        dental_formula: {
          notation: "fdi",
          shade: nil,
          teeth: [ { n: 14, type: nil, material: nil } ],
          connectors: []
        }.to_json
      }
    }
    order.reload
    tooth = order.dental_formula["teeth"].first
    assert_equal 14, tooth["n"]
    assert_nil tooth["type"]
    assert_nil tooth["material"]
  end

  test "odontogram accepts healthy tooth type" do
    order = create_order
    patch work_order_path(order), params: {
      work_order: {
        customer_id: order.customer_id,
        patient_id: order.patient_id,
        dental_formula: {
          notation: "fdi",
          teeth: [ { n: 11, type: "healthy", material: nil } ],
          connectors: []
        }.to_json
      }
    }
    assert_equal "healthy", order.reload.dental_formula["teeth"].first["type"]
  end

  test "employee cannot access work orders" do
    sign_in users(:employee)
    get work_orders_path
    assert_redirected_to root_path
  end

  test "index searches by patient surname fragment" do
    matching = create_order
    other_patient = Patient.create!(full_name: "Петров Пётр", doctor: doctors(:without_customer))
    WorkOrder.create!(
      customer: customers(:clinic),
      patient: other_patient,
      created_by: @admin,
      dental_formula: Odontogram.empty
    )

    get work_orders_path, params: { patient: "Сидорова" }
    assert_response :success
    assert_includes @controller.view_assigns["work_orders"].map(&:id), matching.id
    assert_equal 1, @controller.view_assigns["work_orders"].size
  end

  test "index links to work order show" do
    order = create_order
    get work_orders_path
    assert_response :success
    assert_select "a[href=?]", work_order_path(order), minimum: 1

    get work_order_path(order)
    assert_response :success
    assert_match(/##{order.number}|Наряд/, response.body)
  end

  test "show displays description from notes" do
    order = create_order
    order.update!(notes: "Коронки 14–16, срочно")
    get work_order_path(order)
    assert_response :success
    assert_select "div", text: /Описание/
    assert_match "Коронки 14–16, срочно", response.body
  end

  test "assignee outside pool rejected" do
    order = create_order
    outsider = users(:admin)
    assert_no_difference("WorkOrderService.count") do
      post work_order_work_order_services_path(order), params: {
        work_order_service: {
          service_id: services(:crown).id,
          assignee_id: outsider.id,
          quantity: 1
        }
      }
    end
  end

  test "ready blocked when lines incomplete" do
    order = create_order_with_line
    post advance_work_order_path(order, to: "in_progress")
    post advance_work_order_path(order, to: "ready")
    assert_not_equal "ready", order.reload.status
    assert_match(/Нужна хотя бы одна|запрещён/, flash[:alert].to_s)
  end

  test "customer payment amount persists on unpaid order" do
    order = create_order
    patch work_order_path(order), params: {
      work_order: { customer_payment_amount: "5000.00" }
    }
    order.reload
    assert_equal 5000.0, order.customer_payment_amount.to_f
    assert_not order.customer_paid?
  end

  test "paid order ignores customer_paid fields on update" do
    order = create_order
    order.update!(customer_paid_amount: 1000, customer_paid_at: Time.current)
    patch work_order_path(order), params: {
      work_order: {
        customer_id: order.customer_id,
        patient_id: order.patient_id,
        customer_paid_amount: "1500.00",
        customer_paid_at: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
      }
    }
    order.reload
    assert_equal 1000.0, order.customer_paid_amount.to_f
  end

  test "delivery marks sent" do
    order = create_completed_ready_order
    post mark_sent_delivery_path(order)
    assert_equal "sent", order.reload.status
    assert order.sent_at.present?
  end

  test "closed cannot rollback" do
    order = create_completed_ready_order
    order.advance_to!("closed", by: @admin)
    post rollback_work_order_path(order, to: "ready")
    follow_redirect!
    assert_equal "closed", order.reload.status
  end

  test "completed service line is soft-removed preserving payment history" do
    order = create_completed_ready_order
    line = order.work_order_services.first
    order.update!(status: "in_progress") # allow structure edits while keeping completed line
    line.update!(
      technician_paid: true,
      technician_paid_at: Time.current,
      technician_paid_by: @admin
    )
    event = PaymentEvent.create!(
      event_type: "technician_paid",
      actor: @admin,
      work_order: order,
      work_order_service: line,
      amount: line.amount,
      created_at: Time.current
    )

    sign_in @admin
    get work_order_path(order)
    assert_response :success
    assert_select "button", text: "Снять"

    assert_no_difference("WorkOrderService.count") do
      delete work_order_work_order_service_path(order, line)
    end
    assert_redirected_to work_order_path(order)
    line.reload
    assert line.removed?
    assert_equal @admin.id, line.removed_by_id
    assert_includes order.reload.work_order_services.map(&:id), line.id
    assert_not_includes order.assigned_service_lines.map(&:id), line.id
    assert_equal line.id, event.reload.work_order_service_id

    get reports_payroll_path, params: { from: Date.current.to_s, to: Date.current.to_s }
    assert_response :success
    assert_match line.service.name, response.body
  end

  test "in_progress service line is soft-removed" do
    order = create_order_with_line
    line = order.work_order_services.first
    line.start!(by: @admin)

    sign_in @admin
    assert_no_difference("WorkOrderService.count") do
      delete work_order_work_order_service_path(order, line)
    end
    assert_redirected_to work_order_path(order)
    assert line.reload.removed?
    assert_empty order.reload.assigned_service_lines
  end

  test "paid assigned service line is soft-removed" do
    order = create_order_with_line
    line = order.work_order_services.first
    order.update!(status: "in_progress")
    line.update!(
      technician_paid: true,
      technician_paid_at: Time.current,
      technician_paid_by: @admin
    )

    sign_in @admin
    assert_no_difference("WorkOrderService.count") do
      delete work_order_work_order_service_path(order, line)
    end
    assert_redirected_to work_order_path(order)
    assert line.reload.removed?
  end

  test "soft-removed incomplete line does not block ready" do
    order = create_order_with_line
    stuck = order.work_order_services.first
    stuck.start!(by: @admin)
    stuck.soft_remove!(by: @admin)

    good = order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )
    good.start!(by: @admin)
    good.complete!(by: @admin)

    assert order.reload.all_services_completed?
    order.advance_to!("ready", by: @admin)
    assert_equal "ready", order.reload.status
  end

  test "assigned unpaid service line can be hard deleted" do
    order = create_order_with_line
    line = order.work_order_services.first

    sign_in @admin
    assert_difference("WorkOrderService.count", -1) do
      delete work_order_work_order_service_path(order, line)
    end
    assert_redirected_to work_order_path(order)
  end

  test "work orders index paginates at 40 per page" do
    45.times { create_order }

    get work_orders_path
    assert_response :success
    assert_select "nav[aria-label=Страницы]", text: /из 4[5-9]|из [5-9]\d|из \d{3}/
    assert_select "nav[aria-label=Страницы]", text: /по 40 на странице/
    assert_select "a", text: "Вперёд →"

    get work_orders_path(page: 2)
    assert_response :success
    assert_select "span[aria-current=page]", text: "2"
  end

  private

  def create_order
    WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty
    )
  end

  def create_order_with_line
    order = create_order
    order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )
    order
  end

  def create_completed_ready_order
    order = create_order_with_line
    line = order.work_order_services.first
    line.start!(by: @admin)
    line.complete!(by: @admin)
    order.advance_to!("ready", by: @admin)
    order
  end
end
