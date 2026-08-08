# frozen_string_literal: true

class PaymentPolicy < ApplicationPolicy
  def technician?
    user.present?
  end

  def customer?
    admin_or_superadmin?
  end

  def payouts_index?
    admin_or_superadmin?
  end
end
