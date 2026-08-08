require "application_system_test_case"

class AuthenticationSystemTest < ApplicationSystemTestCase
  test "superadmin signs in and creates a user" do
    visit new_user_session_path
    fill_in "user_email", with: users(:superadmin).email
    fill_in "user_password", with: "password123"
    click_button "Войти"

    assert_text "Dental Lab Manager"
    click_link "Пользователи"
    click_link "Новый пользователь"

    fill_in "user_full_name", with: "Новый Техник"
    fill_in "user_email", with: "new.tech@example.com"
    select "employee", from: "user_role"
    fill_in "user_password", with: "password123"
    fill_in "user_password_confirmation", with: "password123"
    click_button "Создать"

    assert_text "Пользователь создан"
    assert_text "new.tech@example.com"
  end
end
