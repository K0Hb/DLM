class WorkOrderPolicy < CatalogPolicy
  def show?
    admin_or_superadmin? || assigned_employee?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin_or_superadmin?
        scope.all
      elsif user&.employee?
        scope.joins(:work_order_services).merge(WorkOrderService.active).where(work_order_services: { assignee_id: user.id }).distinct
      else
        scope.none
      end
    end
  end

  private

  def assigned_employee?
    user&.employee? && record.work_order_services.active.exists?(assignee_id: user.id)
  end
end
