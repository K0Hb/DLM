require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Dlm
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Europe/Moscow"
    config.i18n.default_locale = :ru
    config.i18n.available_locales = %i[ru en]
    config.i18n.fallbacks = [ :en ]

    # Optional HTTPS behind reverse proxy (FORCE_SSL / ASSUME_SSL ENV).
    config.force_ssl = ActiveModel::Type::Boolean.new.cast(ENV.fetch("FORCE_SSL", "false"))
  end
end
