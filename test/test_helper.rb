ENV["RAILS_ENV"] ||= "test"
# Keep suite independent of developer LAN .env (PUBLIC_BASE_URL, etc.).
ENV.delete("PUBLIC_BASE_URL")
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
