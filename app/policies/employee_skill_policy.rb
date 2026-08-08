class EmployeeSkillPolicy < ApplicationPolicy
  def index?
    admin_or_superadmin?
  end

  def edit?
    admin_or_superadmin? && record.employee?
  end

  def update?
    edit?
  end
end
