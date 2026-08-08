class DeliveriesController < ApplicationController
  def index
    authorize WorkOrder, :index?
    @work_orders = policy_scope(WorkOrder).where(status: "ready").includes(:customer, :patient).order(:number)
  end

  def mark_sent
    @work_order = WorkOrder.find(params[:id])
    authorize @work_order, :update?
    @work_order.advance_to!("sent", by: current_user)
    redirect_to deliveries_path, notice: "Наряд №#{@work_order.number} отправлен."
  rescue WorkOrder::TransitionError => e
    redirect_to deliveries_path, alert: e.message
  end
end
