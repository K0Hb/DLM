# frozen_string_literal: true

module PublicUrlHelper
  def public_base_url
    PublicUrl.base_url(request: request)
  end

  def public_base_url_source
    return :env if PublicUrl.configured_base_url

    request&.host.present? ? :request : :default
  end

  def public_base_url_hint
    case public_base_url_source
    when :env
      "Из PUBLIC_BASE_URL"
    when :request
      "По адресу, с которого вы открыли страницу"
    else
      "По умолчанию (localhost)"
    end
  end

  def work_order_public_url(work_order)
    PublicUrl.work_order_url(work_order, request: request)
  end
end
