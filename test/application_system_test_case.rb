require "test_helper"

# rack_test covers server-rendered UI flows without a browser binary.
# Prefer Selenium headless Chrome when a matching chromedriver is available
# (see README). Override with: DLM_SYSTEM_DRIVER=selenium
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["DLM_SYSTEM_DRIVER"] == "selenium"
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_option|
      driver_option.binary = ENV.fetch("CHROME_BINARY", "/usr/bin/google-chrome")
      driver_option.add_argument("--headless=new")
      driver_option.add_argument("--no-sandbox")
      driver_option.add_argument("--disable-dev-shm-usage")
    end
  else
    driven_by :rack_test
  end
end
