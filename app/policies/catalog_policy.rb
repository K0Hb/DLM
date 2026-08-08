class CatalogPolicy < ApplicationPolicy
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
    admin_or_superadmin?
  end

  def destroy?
    admin_or_superadmin?
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
