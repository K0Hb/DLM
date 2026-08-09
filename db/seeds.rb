# frozen_string_literal: true

email = ENV.fetch("SUPERADMIN_EMAIL", "admin@example.com").strip.downcase
password = ENV.fetch("SUPERADMIN_PASSWORD", "changeme123")
full_name = ENV.fetch("SUPERADMIN_FULL_NAME", "Super Admin")

superadmin = User.find_or_initialize_by(email: email)
superadmin.full_name = full_name
superadmin.role = "superadmin"
superadmin.active = true
superadmin.password = password
superadmin.password_confirmation = password
superadmin.save!

puts "Seeded superadmin: #{superadmin.email}"
puts "Odontogram config: #{Odontogram.known_codes.size} types, #{Odontogram.known_material_codes.size} materials, #{Odontogram.known_shade_codes.size} shades (config/odontogram.yml)"

demo = ENV["SEED_DEMO"] == "1" || (Rails.env.development? && ENV["SKIP_DEMO_SEED"] != "1")
unless demo
  puts "Skip demo seed (set SEED_DEMO=1 or unset SKIP_DEMO_SEED in development)"
  return
end

puts "Seeding demo volume data…"

demo_password = ENV.fetch("DEMO_PASSWORD", "changeme123")

ActiveRecord::Base.transaction do
  PaymentEvent.delete_all
  WorkOrderService.delete_all
  WorkOrder.delete_all
  Patient.delete_all
  Doctor.delete_all
  Customer.delete_all
  ActiveRecord::Base.connection.execute("DELETE FROM services_users")
  Service.delete_all
  User.where.not(id: superadmin.id).delete_all

  admin = User.create!(
    email: "manager@example.com",
    full_name: "Анна Менеджерова",
    role: "admin",
    active: true,
    password: demo_password,
    password_confirmation: demo_password
  )

  employee_specs = [
    "Пётр Короткий",
    "Мария Иванова",
    "Алексей Смирнов",
    "Елена Кузнецова",
    "Дмитрий Попов",
    "Ольга Васильева",
    "Игорь Николаев",
    "Наталья Федорова",
    "Сергей Михайлов",
    "Татьяна Александрова",
    "Владимир Константинович Длиннофамильный-Зуботехнический",
    "Юлия"
  ]

  employees = employee_specs.each_with_index.map do |name, idx|
    User.create!(
      email: "tech#{idx + 1}@example.com",
      full_name: name,
      role: "employee",
      active: idx != 10, # one inactive for UI checks
      password: demo_password,
      password_confirmation: demo_password
    )
  end

  inactive = User.create!(
    email: "inactive-admin@example.com",
    full_name: "Неактивный Админ",
    role: "admin",
    active: false,
    password: demo_password,
    password_confirmation: demo_password
  )

  service_specs = [
    [ "Коронка Zr", "Стандартная циркониевая коронка", 2_500 ],
    [ "Коронка E.max", nil, 2_800 ],
    [ "Винир", "Керамический винир", 3_200 ],
    [ "Вкладка", "", 1_800 ],
    [ "Абатмент индивидуальный", "Ti / Zr", 4_500 ],
    [ "Мост 3 ед.", nil, 7_200 ],
    [ "Каркас CoCr", nil, 1_500 ],
    [ "Временная коронка PMMA", "Провизорная", 900 ],
    [ "Диагностическая модель", nil, 600 ],
    [ "Восковое моделирование", "Wax-up", 1_200 ],
    [ "Каппа ретенционная", nil, 1_100 ],
    [ "Шина", "Окклюзионная", 2_000 ],
    [ "Ремонт скола", "Локальный ремонт", 700 ],
    [ "Перебазировка", nil, 1_400 ],
    [ "Полный съёмный протез", "Акрил", 8_500 ],
    [ "Частичный съёмный протез", nil, 6_200 ],
    [ "Имплант-коронка screw-retained", "Винтовая фиксация", 5_500 ],
    [ "Очень длинное название услуги для проверки переноса в таблицах и печати: металлокерамическая коронка с индивидуализацией десневого края", "Длинное описание " * 12, 3_900 ],
    [ "Коротко", "x", 100 ],
    [ "Фрезеровка Zr диск", nil, 2_200 ],
    [ "Окрашивание и глазурь", "Финиш", 800 ],
    [ "Цифровой дизайн CAD", nil, 1_600 ],
    [ "Слепок / сканирование обработка", nil, 500 ],
    [ "Примерка / коррекция", nil, 400 ],
    [ "Доставка курьером", "Внутри города", 350 ]
  ]

  services = service_specs.map do |name, description, price|
    Service.create!(name: name, description: description, technician_price: price, active: name != "Коротко")
  end

  # Service pools: each tech gets a rotating slice; admin/superadmin get all
  employees.each_with_index do |user, idx|
    pool = services.rotate(idx * 3).first(10)
    user.services = pool
  end
  admin.services = services
  superadmin.services = services

  customer_names = [
    "Клиника «Улыбка»",
    "СТОМАТОЛОГИЯ №1",
    "ДентАрт",
    "Белая жемчужина",
    "ООО «МегаДент Профи Лаборатория Партнёр» — филиал на Васильевском острове",
    "Dr. Smile",
    "А",
    "Семейная стоматология на Лесной",
    "Имплант-центр «Ортодонтия и протезирование полного цикла»",
    "Частный кабинет Петрова",
    "Клиника короткое",
    "Nordic Dental Lab Partner",
    "Зуб.ру",
    "Эстетик Дент",
    "Городская поликлиника №12 (стомат. отделение)",
    "ВитаДент",
    "Лазурный берег",
    "Президент Клиник",
    "Дентал Хаус СПб",
    "Мобильная бригада «Выездной ортопед»"
  ]

  customers = customer_names.each_with_index.map do |name, idx|
    Customer.create!(
      name: name,
      phone: idx.even? ? "+7 (812) #{100 + idx}-#{10 + idx}-#{20 + idx}" : nil,
      email: idx % 3 == 0 ? "clinic#{idx}@example.com" : nil,
      address: idx % 4 == 0 ? "Санкт-Петербург, Невский пр., д. #{idx + 1}" : nil,
      notes: [ nil, "VIP", "Скидка 5%", "Очень длинная заметка по заказчику: предпочитает E.max, срочные заказы только после согласования с главврачом. " * 3 ][idx % 4],
      active: idx != 6
    )
  end

  doctor_first = %w[Иван Пётр Сергей Андрей Михаил Александр Дмитрий Никита Артём Кирилл]
  doctor_last = %w[Иванов Петров Сидоров Козлов Морозов Волков Лебедев Соколов Новиков Фёдоров]
  doctors = []
  customers.each_with_index do |customer, cidx|
    count = (cidx % 3) + 1
    count.times do |i|
      long = cidx == 4 && i.zero?
      doctors << Doctor.create!(
        full_name: long ? "Екатерина Владимировна Очень-Длинная-Фамилия-Ортопед-Имплантолог" : "#{doctor_last[(cidx + i) % doctor_last.size]} #{doctor_first[(cidx * 2 + i) % doctor_first.size]} #{%w[Иванович Петрович Сергеевич].sample}",
        customer: customer,
        phone: i.zero? ? "+7 921 #{1000000 + cidx * 10 + i}" : nil,
        notes: i == 1 ? "Предпочитает Zr" : nil,
        active: !(cidx == 0 && i == 1)
      )
    end
  end
  # Doctors without clinic link
  5.times do |i|
    doctors << Doctor.create!(
      full_name: "Внешний врач #{i + 1} #{'Супердлинноеимя' * (i == 4 ? 3 : 1)}",
      customer: nil,
      active: true
    )
  end

  patient_names = [
    "Анна", "Борис", "Вера", "Глеб", "Дарья", "Егор", "Жанна", "Захар", "Инна", "Кира",
    "Лев", "Мила", "Никита", "Ольга", "Павел", "Рита", "Семён", "Тамара", "Ульяна", "Фёдор"
  ]
  patients = []
  doctors.select(&:active).each_with_index do |doctor, didx|
    n = (didx % 4) + 1
    n.times do |i|
      base = patient_names[(didx + i) % patient_names.size]
      full =
        case (didx + i) % 5
        when 0 then "#{base} Короткая"
        when 1 then "#{base} #{%w[Иванова Петрова Сидорова].sample}"
        when 2 then "#{base} Александровна #{%w[Кузнецова Смирнова].sample}"
        when 3 then "#{base} " + ("Длиннопациентская-" * 4) + "Фамилия"
        else "#{base}"
        end
      patients << Patient.create!(
        full_name: full,
        doctor: doctor,
        notes: i.zero? ? nil : "Аллергия / примечание #{i}"
      )
    end
  end

  shades = Odontogram.known_shade_codes
  types = Odontogram.known_codes - %w[healthy antagonist missing]
  materials = Odontogram.known_material_codes
  statuses = WorkOrder::STATUSES
  line_statuses = WorkOrderService::STATUSES

  long_notes = <<~TEXT.strip
    Длинное описание наряда для проверки печати и вёрстки.

    Пациент просит максимально естественный цвет, особенно в зоне улыбки.
    Учесть высоту десневого края, контакты с антагонистами, лёгкую прозрачность режущего края.
    Материал согласовать с врачом до фрезеровки. Срочность средняя, но примерка желательна до пятницы.
    Дополнительно: #{("повтор детали, " * 40)}
  TEXT

  short_notes = [ nil, "Срочно", "Без примерки", "Цвет уточнить", "Повтор", "—" ]

  work_orders = []
  110.times do |i|
    customer = customers[i % customers.size]
    clinic_doctors = doctors.select { |d| d.customer_id == customer.id && d.active? }
    doctor = clinic_doctors.sample || doctors.sample
    patient_pool = patients.select { |p| p.doctor_id == doctor.id }
    patient =
      if i % 7 == 0
        nil
      else
        patient_pool.sample || patients.sample
      end

    teeth = []
    tooth_count = [ 0, 1, 2, 3, 4, 6, 8 ][i % 7]
    sample_teeth = Odontogram::FDI_TEETH.sample(tooth_count)
    sample_teeth.each do |n|
      teeth << {
        "n" => n,
        "type" => types.sample,
        "material" => (i.even? ? materials.sample : nil)
      }
    end
    connectors =
      if teeth.size >= 2 && i % 5 == 0
        [ [ teeth[0]["n"], teeth[1]["n"] ] ]
      else
        []
      end

    formula = {
      "notation" => "fdi",
      "shade" => (i % 4 == 0 ? nil : shades.sample),
      "teeth" => teeth,
      "connectors" => connectors
    }

    notes =
      case i % 6
      when 0 then long_notes
      when 1 then short_notes.sample
      when 2 then "Среднее описание: коронки #{teeth.map { |t| t['n'] }.join(', ').presence || 'без формулы'}; согласовать tip."
      when 3 then "X" * (20 + (i % 80))
      else short_notes.sample
      end

    status = statuses[i % statuses.size]
    due_at = Time.current + ((i % 20) - 5).days + (i % 8).hours

    order = WorkOrder.create!(
      customer: customer,
      doctor: doctor,
      patient: patient,
      created_by: [ superadmin, admin ].sample,
      due_at: i % 9 == 0 ? nil : due_at,
      notes: notes,
      dental_formula: formula,
      customer_payment_amount: [ 0, 5_000, 12_500, 28_000, 99_999.99 ][i % 5],
      material_note: i % 11 == 0 ? "Особый сплав / индивидуальный абтмент длинная пометка для UI" : nil
    )

    # Attach 1–4 service lines while order is still editable
    line_count = (i % 4) + 1
    lines = []
    line_count.times do |li|
      service = services[(i + li) % services.size]
      assignee = employees.select { |e| e.active? && e.services.include?(service) }.sample || employees.first
      assignee.services << service unless assignee.services.include?(service)

      line = WorkOrderService.create!(
        work_order: order,
        service: service,
        assignee: assignee,
        quantity: (li % 3) + 1,
        notes: li.zero? ? nil : "Коммент к строке #{li}: " + ("деталь " * (li * 5))
      )
      lines << line
    end

    # Progress lines / payments according to desired order status
    case status
    when "draft"
      # leave lines assigned (sometimes empty — wipe for a few)
      if i % 17 == 0
        lines.each(&:destroy!)
      end
    when "in_progress"
      lines.each_with_index do |line, li|
        st = line_statuses[li % line_statuses.size]
        case st
        when "in_progress"
          line.update_columns(status: "in_progress", started_at: 2.days.ago)
        when "completed"
          line.update_columns(status: "in_progress", started_at: 3.days.ago)
          line.update_columns(status: "completed", completed_at: 1.day.ago)
        end
      end
      order.update_columns(status: "in_progress")
    when "ready", "sent", "closed"
      lines.each do |line|
        line.update_columns(
          status: "completed",
          started_at: 5.days.ago,
          completed_at: 2.days.ago
        )
      end
      sent_at = status.in?(%w[sent closed]) ? 1.day.ago : nil
      closed_at = status == "closed" ? 12.hours.ago : nil
      order.update_columns(status: status, sent_at: sent_at, closed_at: closed_at)
    end

    # Soft-remove a line on some in-progress / ready orders (re-open structure if closed skipped)
    if status.in?(%w[in_progress ready]) && lines.size > 1 && i % 8 == 0
      victim = lines.last
      victim.update_columns(removed_at: Time.current, removed_by_id: admin.id) unless victim.removed?
    end

    # Customer paid on some orders
    if i % 3 == 0 && order.customer_payment_amount.to_d.positive?
      amount = order.customer_payment_amount
      order.update_columns(
        customer_paid_amount: amount,
        customer_paid_at: 3.days.ago,
        customer_paid_by_id: admin.id
      )
      PaymentEvent.create!(
        event_type: "customer_paid",
        actor: admin,
        work_order: order,
        amount: amount,
        note: "Демо оплата заказчиком",
        created_at: 3.days.ago
      )
    end

    # Technician payouts on completed lines
    order.work_order_services.reload.each_with_index do |line, li|
      next unless line.completed? && !line.removed?
      next unless i.even? && li.even?

      line.update_columns(
        technician_paid: true,
        technician_paid_at: 1.day.ago,
        technician_paid_by_id: admin.id
      )
      PaymentEvent.create!(
        event_type: "technician_paid",
        actor: admin,
        work_order: order,
        work_order_service: line,
        amount: line.amount,
        note: "Демо выплата",
        created_at: 1.day.ago
      )
    end

    work_orders << order
  end

  puts "Demo users: 1 superadmin + #{User.where.not(id: superadmin.id).count} (password: #{demo_password})"
  puts "  admin login: manager@example.com"
  puts "  employee login: tech1@example.com … tech#{employees.size}@example.com"
  puts "Customers: #{Customer.count}, doctors: #{Doctor.count}, patients: #{Patient.count}"
  puts "Services: #{Service.count}, work orders: #{WorkOrder.count}, lines: #{WorkOrderService.count}"
  puts "Payment events: #{PaymentEvent.count}"
  puts "Statuses mix: #{WorkOrder.group(:status).count.sort.to_h}"
end
