# frozen_string_literal: true

module PaymentsHelper
  def technician_paid_badge(line)
    if line.technician_paid?
      content_tag(:span, "Оплачено", class: "rounded bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-800")
    else
      content_tag(:span, "Не оплачено", class: "rounded bg-red-100 px-2 py-0.5 text-xs font-medium text-red-800")
    end
  end

  def customer_paid_badge(work_order)
    if work_order.customer_paid?
      content_tag(:span, "Оплачен заказчиком", class: "rounded bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-800")
    else
      content_tag(:span, "Не оплачен", class: "rounded bg-red-100 px-2 py-0.5 text-xs font-medium text-red-800")
    end
  end
end
