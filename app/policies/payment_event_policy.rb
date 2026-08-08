# frozen_string_literal: true

class PaymentEventPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin_or_superadmin?
        scope.all
      elsif user&.employee?
        scope.technician_events.for_assignee(user.id)
      else
        scope.none
      end
    end
  end
end
