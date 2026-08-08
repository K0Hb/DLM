class WorkOrderServicePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    admin_or_superadmin? || assignee?
  end

  def create?
    admin_or_superadmin?
  end

  def update?
    admin_or_superadmin?
  end

  def destroy?
    admin_or_superadmin? && record.deletable?
  end

  def start?
    admin_or_superadmin? || assignee?
  end

  def complete?
    admin_or_superadmin? || assignee?
  end

  def attach_photos?
    admin_or_superadmin? || assignee?
  end

  def payout?
    return false unless record.payout_eligible?
    return true if admin_or_superadmin?
    assignee?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin_or_superadmin?
        scope.all
      elsif user&.employee?
        scope.where(assignee_id: user.id)
      else
        scope.none
      end
    end
  end

  private

  def assignee?
    user.present? && record.assignee_id == user.id
  end
end
