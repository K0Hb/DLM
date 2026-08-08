ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Load .env without dotenv gem (PUBLIC_BASE_URL, DB, etc.). Existing ENV wins.
# Skip in test so CI/local suite stays deterministic (no LAN PUBLIC_BASE_URL bleed-in).
env_path = File.expand_path("../.env", __dir__)
if File.exist?(env_path) && ENV["RAILS_ENV"] != "test" && ENV["RACK_ENV"] != "test"
  File.foreach(env_path) do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")
    key, value = line.split("=", 2)
    next if key.nil? || value.nil?

    ENV[key] ||= value.delete_prefix('"').delete_prefix("'").delete_suffix('"').delete_suffix("'")
  end
end
