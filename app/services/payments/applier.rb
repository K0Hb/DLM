# frozen_string_literal: true

module Payments
  class Error < StandardError; end
  class Locked < Error; end
  class Forbidden < Error; end
  class Invalid < Error; end

  class Applier
    LOCK_AFTER = 30.days

    def initialize(actor:)
      @actor = actor
    end

    def apply_technician!(lines:, paid:, paid_at: Time.current, note: nil)
      lines = Array(lines).compact
      raise Invalid, "Не выбраны услуги" if lines.empty?

      ActiveRecord::Base.transaction do
        lines.each { |line| toggle_technician!(line, paid: paid, paid_at: paid_at, note: note) }
      end
    end

    def apply_customer!(orders:, paid:, paid_at: Time.current, note: nil, amount: nil)
      orders = Array(orders).compact
      raise Invalid, "Не выбраны наряды" if orders.empty?
      raise Forbidden, "Нет прав" unless @actor.admin_or_superadmin?

      ActiveRecord::Base.transaction do
        orders.each { |order| toggle_customer!(order, paid: paid, paid_at: paid_at, note: note, amount: amount) }
      end
    end

    def self.technician_payable?(line)
      line.assignee_id.present? && line.work_order.present? && !line.work_order.draft?
    end

    def self.technician_locked?(line, actor:)
      return false unless line.technician_paid? && line.technician_paid_at.present?
      return false if actor.superadmin?
      return false if line.technician_paid_at > LOCK_AFTER.ago

      true
    end

    private

    def toggle_technician!(line, paid:, paid_at:, note:)
      raise Invalid, "Услуга недоступна для оплаты сотруднику" unless self.class.technician_payable?(line)
      raise Forbidden, "Нет прав" unless can_manage_technician?(line)
      raise Locked, "Нельзя менять оплату старше 30 дней" if changing_technician?(line, paid) && self.class.technician_locked?(line, actor: @actor)

      if paid
        line.update!(
          technician_paid: true,
          technician_paid_at: paid_at,
          technician_paid_by: @actor
        )
        log!("technician_paid", work_order_service: line, work_order: line.work_order, amount: line.amount, note: note)
      else
        amount = line.amount
        line.update!(
          technician_paid: false,
          technician_paid_at: nil,
          technician_paid_by: @actor
        )
        log!("technician_unpaid", work_order_service: line, work_order: line.work_order, amount: amount, note: note)
      end
    end

    def toggle_customer!(order, paid:, paid_at:, note:, amount:)
      if paid
        raise Invalid, "Укажите сумму оплаты заказчиком" if amount.blank?

        pay_amount = amount.to_d
        raise Invalid, "Сумма оплаты должна быть больше 0" if pay_amount <= 0

        order.update!(
          customer_paid_amount: pay_amount,
          customer_payment_amount: pay_amount,
          customer_paid_at: paid_at,
          customer_paid_by: @actor
        )
        log!("customer_paid", work_order: order, amount: pay_amount, note: note)
      else
        prev = order.customer_paid_amount
        order.update!(
          customer_paid_amount: 0,
          customer_paid_at: nil,
          customer_paid_by: @actor
        )
        log!("customer_unpaid", work_order: order, amount: prev, note: note)
      end
    end

    def changing_technician?(line, paid)
      line.technician_paid? != paid
    end

    def can_manage_technician?(line)
      @actor.admin_or_superadmin? || @actor.id == line.assignee_id
    end

    def log!(event_type, amount:, note:, work_order: nil, work_order_service: nil)
      PaymentEvent.create!(
        event_type: event_type,
        actor: @actor,
        work_order: work_order,
        work_order_service: work_order_service,
        amount: amount,
        note: note,
        created_at: Time.current
      )
    end
  end
end
