require "application_system_test_case"

class WorkOrdersSystemTest < ApplicationSystemTestCase
  test "admin creates work order via UI" do
    visit new_user_session_path
    fill_in "user_email", with: users(:admin).email
    fill_in "user_password", with: "password123"
    click_button "Войти"

    click_link "Наряды"
    click_link "Новый наряд"
    select customers(:clinic).name, from: "work_order_customer_id"
    fill_in "new_patient_full_name", with: "Системный Пациент"
    click_button "Сохранить"

    assert_text "Наряд создан"
    assert_text "Наряд №"
    assert_text "Системный Пациент"
  end
end
