class UserPolicy < ApplicationPolicy
  def index?
    admin_or_superadmin?
  end

  def show?
    admin_or_superadmin?
  end

  def create?
    admin_or_superadmin?
  end

  def update?
    return false unless admin_or_superadmin?
    return true if user.superadmin?

    record.employee?
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin_or_superadmin?
        scope.all
      else
        scope.none
      end
    end
  end
end
