require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "unauthenticated root redirects to login" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "active user can sign in" do
    post user_session_path, params: {
      user: { email: users(:superadmin).email, password: "password123" }
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_match "Dental Lab Manager", response.body
  end

  test "inactive user cannot sign in" do
    post user_session_path, params: {
      user: { email: users(:inactive).email, password: "password123" }
    }
    assert_response :redirect
    assert_redirected_to new_user_session_path
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "employee cannot access users index" do
    sign_in users(:employee)
    get users_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "нет прав", response.body
  end

  test "admin can access users index and create employee" do
    sign_in users(:admin)
    get users_path
    assert_response :success
    assert_match "Пользователи", response.body

    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          full_name: "Новый Техник",
          email: "admin-created@example.com",
          role: "admin",
          active: true,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to users_path
    assert_equal "employee", User.find_by!(email: "admin-created@example.com").role
  end

  test "admin can view user show with assigned services" do
    sign_in users(:admin)
    employee = users(:employee)
    employee.services << services(:crown) unless employee.services.exists?(services(:crown).id)

    order = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: users(:admin),
      dental_formula: Odontogram.empty
    )
    order.work_order_services.create!(
      service: services(:crown),
      assignee: employee,
      quantity: 1,
      status: "in_progress",
      started_at: Time.current
    )

    get user_path(employee)
    assert_response :success
    assert_match employee.full_name, response.body
    assert_match services(:crown).name, response.body
    assert_match "##{order.number}", response.body
    assert_match "В работе", response.body
  end

  test "admin cannot edit another admin" do
    sign_in users(:admin)
    get edit_user_path(users(:admin))
    assert_redirected_to root_path
  end

  test "superadmin can access users index" do
    sign_in users(:superadmin)
    get users_path
    assert_response :success
    assert_match "Пользователи", response.body
  end

  test "superadmin can create a user" do
    sign_in users(:superadmin)
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          full_name: "Новый Техник",
          email: "new.tech@example.com",
          role: "employee",
          active: true,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to users_path
    follow_redirect!
    assert_match "Пользователь создан", response.body
    assert_match "new.tech@example.com", response.body
  end
end
