require "test_helper"

class CatalogsTest < ActionDispatch::IntegrationTest
  test "employee cannot access customers" do
    sign_in users(:employee)
    get customers_path
    assert_redirected_to root_path
  end

  test "admin can create customer" do
    sign_in users(:admin)
    assert_difference("Customer.count", 1) do
      post customers_path, params: { customer: { name: "Новая клиника", active: true } }
    end
    assert_redirected_to customer_path(Customer.order(:id).last)
  end

  test "admin can create doctor without customer" do
    sign_in users(:admin)
    assert_difference("Doctor.count", 1) do
      post doctors_path, params: { doctor: { full_name: "Смирнов С.С.", active: true } }
    end
    assert_redirected_to doctor_path(Doctor.order(:id).last)
  end

  test "admin can create patient with doctor" do
    sign_in users(:admin)
    assert_difference("Patient.count", 1) do
      post patients_path, params: { patient: { full_name: "Тестов Т.Т.", doctor_id: doctors(:ivanov).id } }
    end
    patient = Patient.order(:id).last
    assert_redirected_to patient_path(patient)
    assert_equal doctors(:ivanov).id, patient.doctor_id
  end

  test "admin cannot create patient without doctor" do
    sign_in users(:admin)
    assert_no_difference("Patient.count") do
      post patients_path, params: { patient: { full_name: "Без Врача" } }
    end
    assert_response :unprocessable_entity
  end

  test "patient and doctor show list related work orders" do
    sign_in users(:admin)
    order = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      doctor: doctors(:ivanov),
      created_by: users(:admin),
      dental_formula: Odontogram.empty
    )

    get patient_path(patients(:anna))
    assert_response :success
    assert_match(/##{order.number}/, response.body)
    assert_select "a", text: "Открыть"

    get doctor_path(doctors(:ivanov))
    assert_response :success
    assert_match(/##{order.number}/, response.body)
    assert_match patients(:anna).full_name, response.body
    assert_select "a", text: "Открыть"

    get customer_path(customers(:clinic))
    assert_response :success
    assert_match(/##{order.number}/, response.body)
    assert_select "a", text: "Открыть"
  end

  test "admin can create service with technician price" do
    sign_in users(:admin)
    assert_difference("Service.count", 1) do
      post services_path, params: {
        service: { name: "Вкладка", technician_price: "750.50", active: true }
      }
    end
    assert_redirected_to service_path(Service.find_by!(name: "Вкладка"))
    assert_equal 750.50, Service.find_by!(name: "Вкладка").technician_price
  end

  test "admin service show has delete not on index" do
    sign_in users(:admin)
    service = services(:crown)

    get services_path
    assert_response :success
    assert_select "a", text: "Открыть"
    assert_select "button", text: "Удалить", count: 0

    get service_path(service)
    assert_response :success
    assert_select "button", text: "Удалить", count: 1
  end

  test "admin cannot delete service used in work orders" do
    sign_in users(:admin)
    service = services(:crown)
    employee = users(:employee)
    employee.services << service unless employee.services.exists?(service.id)
    WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: users(:admin),
      dental_formula: Odontogram.empty,
      work_order_services: [
        WorkOrderService.new(
          service: service,
          assignee: employee,
          quantity: 1
        )
      ]
    )

    assert_no_difference("Service.count") do
      delete service_path(service)
    end
    assert_redirected_to service_path(service)
    assert_match(/используется в нарядах/, flash[:alert].to_s)
  end

  test "admin can delete unused service" do
    sign_in users(:admin)
    service = Service.create!(name: "Удаляемая", technician_price: 100, active: true)

    assert_difference("Service.count", -1) do
      delete service_path(service)
    end
    assert_redirected_to services_path
  end

  test "admin can assign service pool to employee" do
    sign_in users(:admin)
    employee = users(:employee)
    patch user_path(employee), params: {
      service_pool: "1",
      user: { service_ids: [ services(:crown).id, services(:veneer).id ] }
    }
    assert_redirected_to user_path(employee)
    assert_equal [ "Винир", "Коронка Zr" ], employee.reload.services.order(:name).pluck(:name)
  end

  test "employee cannot manage service pool" do
    sign_in users(:employee)
    get user_path(users(:employee))
    assert_redirected_to root_path
  end
end
