# frozen_string_literal: true

email = ENV.fetch("SUPERADMIN_EMAIL", "admin@example.com").strip.downcase
password = ENV.fetch("SUPERADMIN_PASSWORD", "changeme123")
full_name = ENV.fetch("SUPERADMIN_FULL_NAME", "Super Admin")

user = User.find_or_initialize_by(email: email)
user.full_name = full_name
user.role = "superadmin"
user.active = true
user.password = password
user.password_confirmation = password
user.save!

puts "Seeded superadmin: #{user.email}"
puts "Odontogram config: #{Odontogram.known_codes.size} types, #{Odontogram.known_material_codes.size} materials, #{Odontogram.known_shade_codes.size} shades (config/odontogram.yml)"
