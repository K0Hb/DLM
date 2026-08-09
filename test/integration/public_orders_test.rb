require "test_helper"

class PublicOrdersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @order = WorkOrder.create!(
      customer: customers(:clinic),
      patient: patients(:anna),
      created_by: @admin,
      dental_formula: {
        "notation" => "fdi",
        "shade" => "A2",
        "teeth" => [ { "n" => 14, "type" => "crown", "material" => "zirconia" } ],
        "connectors" => []
      },
      notes: "Публичное описание",
      customer_paid_amount: 2500,
      customer_paid_at: Time.current
    )
    @employee = users(:employee)
    @employee.services << services(:crown) unless @employee.services.exists?(services(:crown).id)
    @order.work_order_services.create!(
      service: services(:crown),
      assignee: @employee,
      quantity: 1
    )
  end

  test "anonymous can view public work order by token" do
    get public_order_path(@order.public_token)
    assert_response :success
    assert_match(/Наряд №#{@order.number}/, response.body)
    assert_match(/Анна Сидорова|#{Regexp.escape(patients(:anna).full_name)}/, response.body)
    assert_match(/Публичное описание/, response.body)
    assert_match(/2500|2[\s\u00a0]?500/, response.body)
    assert_select ".odontogram-svg"
  end

  test "unknown token returns not found" do
    get public_order_path("missing-token-xyz")
    assert_response :not_found
  end

  test "admin work order show includes public url and qr" do
    sign_in @admin
    get work_order_path(@order)
    assert_response :success
    assert_match %r{/o/#{Regexp.escape(@order.public_token)}}, response.body
    assert_match(/Публичная ссылка|QR/, response.body)
    assert_select "svg"
  end

  test "public url uses PUBLIC_BASE_URL when set" do
    previous = ENV["PUBLIC_BASE_URL"]
    ENV["PUBLIC_BASE_URL"] = "https://dlm.example.com"
    sign_in @admin
    get work_order_path(@order)
    assert_response :success
    assert_match "https://dlm.example.com/o/#{@order.public_token}", response.body
  ensure
    if previous
      ENV["PUBLIC_BASE_URL"] = previous
    else
      ENV.delete("PUBLIC_BASE_URL")
    end
  end

  test "anonymous public page has no internal work order link but offers sign in" do
    get public_order_path(@order.public_token)
    assert_response :success
    assert_select "a[href=?]", work_order_path(@order), count: 0
    assert_select "a[href=?]", new_user_session_path, text: "Войти"
  end

  test "assigned employee sees open work order link on public page" do
    sign_in @employee
    get public_order_path(@order.public_token)
    assert_response :success
    assert_select "a[href=?]", work_order_path(@order), text: "Открыть наряд"
  end

  test "admin sees open work order link on public page" do
    sign_in @admin
    get public_order_path(@order.public_token)
    assert_response :success
    assert_select "a[href=?]", work_order_path(@order), text: "Открыть наряд"
  end

  test "employee without assignment has no internal link on public page" do
    other = users(:employee).dup
    other.assign_attributes(
      email: "other.tech@example.com",
      full_name: "Другой Техник",
      password: "password123",
      password_confirmation: "password123"
    )
    other.save!
    sign_in other
    get public_order_path(@order.public_token)
    assert_response :success
    assert_select "a[href=?]", work_order_path(@order), count: 0
  end
end
