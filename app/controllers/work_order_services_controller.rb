class WorkOrderServicesController < ApplicationController
  before_action :set_work_order
  before_action :set_line, only: %i[update destroy start complete rollback]

  def create
    @line = @work_order.work_order_services.build(line_params)
    authorize @line
    if @line.save
      redirect_to @work_order, notice: "Услуга добавлена."
    else
      redirect_to @work_order, alert: @line.errors.full_messages.to_sentence
    end
  end

  def update
    authorize @line
    if @line.update(line_params)
      redirect_to @work_order, notice: "Строка обновлена."
    else
      redirect_to @work_order, alert: @line.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @line.completed?
      redirect_to @work_order, alert: "Выполненную услугу нельзя удалить — это испортит историю и оплаты сотрудникам."
      return
    end

    authorize @line
    @line.destroy!
    redirect_to @work_order, notice: "Строка удалена."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to @work_order, alert: "Выполненную услугу нельзя удалить — это испортит историю и оплаты сотрудникам."
  end

  def start
    authorize @line, :start?
    @line.start!(by: current_user)
    redirect_to @work_order, notice: "Услуга в работе."
  rescue WorkOrder::TransitionError => e
    redirect_to @work_order, alert: e.message
  end

  def complete
    authorize @line, :complete?
    @line.complete!(by: current_user)
    redirect_to @work_order, notice: "Услуга выполнена."
  rescue WorkOrder::TransitionError => e
    redirect_to @work_order, alert: e.message
  end

  def rollback
    authorize @line, :update?
    target = params.require(:to)
    if target == "in_progress"
      @line.rollback_to_in_progress!(by: current_user)
    elsif target == "assigned"
      @line.rollback_to_assigned!(by: current_user)
    else
      raise WorkOrder::TransitionError, "Неизвестный откат"
    end
    redirect_to @work_order, notice: "Откат строки выполнен."
  rescue WorkOrder::TransitionError => e
    redirect_to @work_order, alert: e.message
  end

  private

  def set_work_order
    @work_order = WorkOrder.find(params[:work_order_id])
  end

  def set_line
    @line = @work_order.work_order_services.find(params[:id])
  end

  def line_params
    params.require(:work_order_service).permit(:service_id, :assignee_id, :quantity, :notes)
  end
end
