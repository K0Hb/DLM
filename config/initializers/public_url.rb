# frozen_string_literal: true

# PUBLIC_BASE_URL is for QR/public links (see PublicUrl) and mailer absolute URLs.
# Do NOT set action_controller/routes default_url_options from it — that makes
# redirect_to generate absolute URLs to the LAN/public host while the admin may
# be browsing via localhost (or the reverse), which raises UnsafeRedirectError.

if ENV["PUBLIC_BASE_URL"].present?
  uri = URI.parse(ENV.fetch("PUBLIC_BASE_URL"))
  url_options = {
    host: uri.host,
    protocol: uri.scheme
  }
  url_options[:port] = uri.port if uri.port && uri.port != uri.default_port

  Rails.application.config.action_mailer.default_url_options = url_options
end
