require "test_helper"

class MyTasksTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @employee = users(:employee)
    @employee.services << services(:crown) unless @employee.services.exists?(services(:crown).id)
    @order = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty
    )
    @line = @order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 2
    )
  end

  test "employee sees only own tasks" do
    other = User.create!(
      email: "other-tech@example.com",
      password: "password123",
      password_confirmation: "password123",
      full_name: "Other Tech",
      role: "employee",
      active: true
    )
    other.services << services(:crown)
    @order.work_order_services.create!(
      service: services(:crown),
      assignee: other,
      quantity: 1
    )

    sign_in @employee
    get my_tasks_path
    assert_response :success
    assert_select "td", text: /#{Regexp.escape(services(:crown).name)}/
    assert_equal 1, @controller.view_assigns["lines"].size
  end

  test "employee starts and completes own line" do
    sign_in @employee
    post start_my_task_path(@line)
    assert_equal "in_progress", @line.reload.status
    assert_equal "in_progress", @order.reload.status

    post complete_my_task_path(@line)
    assert_equal "completed", @line.reload.status
    assert @line.completed_at.present?
  end

  test "employee cannot open foreign line" do
    other = User.create!(
      email: "other2@example.com",
      password: "password123",
      password_confirmation: "password123",
      full_name: "Other2",
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
    get my_task_path(foreign)
    assert_response :not_found
  end

  test "employee attaches jpeg photo on own line" do
    sign_in @employee
    file = fixture_file_upload("test_photo.jpg", "image/jpeg")
    assert_difference -> { @line.photos.count }, 1 do
      post attach_photos_my_task_path(@line), params: { work_order_service: { photos: [ file ] } }
    end
    assert_redirected_to my_task_path(@line)
  end

  test "rejects non-image upload" do
    sign_in @employee
    file = fixture_file_upload("not_image.txt", "text/plain")
    assert_no_difference -> { @line.photos.count } do
      post attach_photos_my_task_path(@line), params: { work_order_service: { photos: [ file ] } }
    end
    assert_match(/JPEG|PNG|WebP|фото/i, flash[:alert].to_s)
  end

  test "admin attaches photo on work order" do
    sign_in @admin
    file = fixture_file_upload("test_photo.jpg", "image/jpeg")
    assert_difference -> { @order.photos.count }, 1 do
      post attach_photos_work_order_path(@order), params: { work_order: { photos: [ file ] } }
    end
  end

  test "employee can view assigned work order read-only" do
    sign_in @employee
    get work_order_path(@order)
    assert_response :success
    assert_no_match "Изменить", response.body
    assert_match @order.number.to_s, response.body
  end

  test "employee cannot view unassigned work order" do
    other_order = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: Odontogram.empty
    )

    sign_in @employee
    get work_order_path(other_order)
    assert_redirected_to root_path
  end

  test "admin cannot access employee cabinet" do
    sign_in @admin
    get my_tasks_path
    assert_redirected_to root_path
  end

  test "completed sum shown for period filter" do
    @line.start!(by: @admin)
    @line.complete!(by: @admin)
    sign_in @employee
    get my_tasks_path, params: {
      status: "completed",
      from: Date.current.to_s,
      to: Date.current.to_s
    }
    assert_response :success
    assert_equal @line.amount, @controller.view_assigns["completed_sum"]
  end
end
