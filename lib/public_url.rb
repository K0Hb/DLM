# frozen_string_literal: true

module PublicUrl
  module_function

  def configured_base_url
    ENV["PUBLIC_BASE_URL"].presence&.delete_suffix("/")
  end

  def base_url(request: nil)
    return configured_base_url if configured_base_url

    if request
      request.base_url
    else
      default_base_url
    end
  end

  def work_order_url(work_order, request: nil)
    "#{base_url(request: request)}/o/#{work_order.public_token}"
  end

  def default_base_url
    opts = Rails.application.routes.default_url_options.presence ||
           Rails.application.config.action_controller.default_url_options ||
           {}

    host = opts[:host] || "localhost"
    port = opts[:port]
    protocol = if Rails.application.config.force_ssl
      "https"
    else
      opts[:protocol] || "http"
    end

    if port.present? && port != 80 && port != 443
      "#{protocol}://#{host}:#{port}"
    else
      "#{protocol}://#{host}"
    end
  end
end
