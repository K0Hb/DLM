# frozen_string_literal: true

require "test_helper"

class PublicUrlTest < ActiveSupport::TestCase
  test "configured base url strips trailing slash" do
    previous = ENV["PUBLIC_BASE_URL"]
    ENV["PUBLIC_BASE_URL"] = "https://dlm.example.com/"
    assert_equal "https://dlm.example.com", PublicUrl.base_url
  ensure
    restore_env("PUBLIC_BASE_URL", previous)
  end

  test "work order url joins token" do
    previous = ENV["PUBLIC_BASE_URL"]
    ENV["PUBLIC_BASE_URL"] = "https://dlm.example.com"
    order = WorkOrder.new(public_token: "abc123")
    assert_equal "https://dlm.example.com/o/abc123", PublicUrl.work_order_url(order)
  ensure
    restore_env("PUBLIC_BASE_URL", previous)
  end

  private

  def restore_env(key, value)
    if value
      ENV[key] = value
    else
      ENV.delete(key)
    end
  end
end
