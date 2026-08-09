class ReportPolicy < ApplicationPolicy
  def index?
    admin_or_superadmin?
  end

  def work_orders?
    admin_or_superadmin?
  end

  def payroll?
    admin_or_superadmin?
  end

  def unpaid?
    admin_or_superadmin?
  end

  def funnel?
    admin_or_superadmin?
  end

  def customers?
    admin_or_superadmin?
  end

  def services?
    admin_or_superadmin?
  end
end
