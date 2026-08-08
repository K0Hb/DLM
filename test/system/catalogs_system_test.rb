require "application_system_test_case"

class CatalogsSystemTest < ApplicationSystemTestCase
  test "admin creates a service via UI" do
    visit new_user_session_path
    fill_in "user_email", with: users(:admin).email
    fill_in "user_password", with: "password123"
    click_button "Войти"

    click_link "Услуги"
    click_link "Добавить"
    fill_in "service_name", with: "Модель"
    fill_in "service_technician_price", with: "500"
    click_button "Сохранить"

    assert_text "Услуга: сохранено"
    assert_text "Модель"
  end
end
