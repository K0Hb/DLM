# frozen_string_literal: true

module ApplicationHelper
  WORK_ORDER_STATUS_LABELS = {
    "draft" => "Черновик",
    "in_progress" => "В работе",
    "ready" => "Готов",
    "sent" => "Отправлен",
    "closed" => "Закрыт"
  }.freeze

  WORK_ORDER_STATUS_BADGE_CLASSES = {
    "draft" => "bg-slate-100 text-slate-700",
    "in_progress" => "bg-amber-100 text-amber-900",
    "ready" => "bg-emerald-100 text-emerald-800",
    "sent" => "bg-sky-100 text-sky-800",
    "closed" => "bg-slate-200 text-slate-800"
  }.freeze

  SERVICE_LINE_STATUS_LABELS = {
    "assigned" => "Назначена",
    "in_progress" => "В работе",
    "completed" => "Выполнена"
  }.freeze

  USER_ROLE_LABELS = {
    "superadmin" => "Суперадмин",
    "admin" => "Админ",
    "employee" => "Сотрудник"
  }.freeze

  SERVICE_LINE_STATUS_BADGE_CLASSES = {
    "assigned" => "bg-amber-100 text-amber-900",
    "in_progress" => "bg-sky-100 text-sky-800",
    "completed" => "bg-emerald-100 text-emerald-800"
  }.freeze

  def user_role_label(role)
    USER_ROLE_LABELS[role.to_s] || role.to_s
  end

  def record_link(text, path)
    link_to text, path, class: "font-medium text-slate-900 underline"
  end

  def open_record_link(path, label: "Открыть")
    link_to label, path, class: "rounded border px-2 py-1 text-xs hover:bg-white"
  end

  def work_order_status_label(status)
    WORK_ORDER_STATUS_LABELS[status.to_s] || status.to_s
  end

  def work_order_status_options(include_blank: nil)
    opts = WorkOrder::STATUSES.map { |s| [ work_order_status_label(s), s ] }
    include_blank ? [ [ include_blank, "" ] ] + opts : opts
  end

  def work_order_status_badge(order_or_status)
    status = order_or_status.respond_to?(:status) ? order_or_status.status : order_or_status.to_s
    content_tag(
      :span,
      work_order_status_label(status),
      class: "inline-flex rounded px-2 py-0.5 text-xs font-medium #{WORK_ORDER_STATUS_BADGE_CLASSES[status] || 'bg-slate-100 text-slate-700'}"
    )
  end

  def service_line_status_label(status)
    SERVICE_LINE_STATUS_LABELS[status.to_s] || status.to_s
  end

  def service_line_status_options(include_blank: nil)
    opts = WorkOrderService::STATUSES.map { |s| [ service_line_status_label(s), s ] }
    include_blank ? [ [ include_blank, "" ] ] + opts : opts
  end

  def service_line_status_badge(line_or_status)
    status = line_or_status.respond_to?(:status) ? line_or_status.status : line_or_status.to_s
    content_tag(
      :span,
      service_line_status_label(status),
      class: "inline-flex rounded px-2 py-0.5 text-xs font-medium #{SERVICE_LINE_STATUS_BADGE_CLASSES[status] || 'bg-slate-100 text-slate-700'}"
    )
  end

  def work_order_service_delete_confirm(line)
    message = "Удалить услугу «#{line.service.name}» из наряда?"
    warnings = []
    warnings << "статус: #{service_line_status_label(line.status)}" unless line.assigned?
    warnings << "оплата сотруднику уже зафиксирована" if line.technician_paid?
    if warnings.any?
      message += "\n\nВнимание: #{warnings.join('; ')}."
    end
    message += "\n\nДействие нельзя отменить."
    message
  end

  def work_order_rollback_confirm(order, target)
    label = work_order_status_label(target)
    message = "Откатить наряд №#{order.number} в «#{label}»?"
    case target
    when "draft"
      message += "\n\nСостав услуг снова можно будет менять."
    when "ready"
      message += "\n\nДата отправки будет сброшена."
    end
    message += "\n\nПродолжить?"
    message
  end

  def work_order_pipeline_step_state(order, step)
    steps = WorkOrder::STATUSES
    current = steps.index(order.status) || 0
    index = steps.index(step) || 0
    if index < current
      :done
    elsif index == current
      :current
    else
      :upcoming
    end
  end

  def work_order_pipeline_segment_classes(state)
    case state
    when :done then "bg-emerald-500"
    when :current then "bg-slate-800"
    else "bg-slate-200"
    end
  end
end
