class MyTasksController < ApplicationController
  include EmployeeCabinet

  before_action :set_line, only: %i[show start complete attach_photos purge_photo]

  def index
    authorize WorkOrderService
    @tab = params[:tab].to_s == "earnings" ? "earnings" : "tasks"
    scope = policy_scope(WorkOrderService).includes(:service, work_order: %i[patient customer])
    scope = scope.where(status: params[:status]) if @tab == "tasks" && params[:status].present?
    scope = scope.where(technician_paid: true) if params[:paid] == "yes"
    scope = scope.where(technician_paid: false) if params[:paid] == "no"
    scope = apply_period_filter(scope)
    @completed_sum = scope.where(status: "completed").sum(Arel.sql("quantity * technician_price_snapshot"))
    @paid_sum = scope.where(technician_paid: true).sum(Arel.sql("quantity * technician_price_snapshot"))
    @unpaid_sum = scope.where(technician_paid: false).sum(Arel.sql("quantity * technician_price_snapshot"))
    @lines = scope.order(updated_at: :desc)
  end

  def show
    authorize @line
    @work_order = @line.work_order
  end

  def start
    authorize @line, :start?
    @line.start!(by: current_user)
    redirect_to my_task_path(@line), notice: "Услуга взята в работу."
  rescue WorkOrder::TransitionError => e
    redirect_to my_task_path(@line), alert: e.message
  end

  def complete
    authorize @line, :complete?
    @line.complete!(by: current_user)
    redirect_to my_task_path(@line), notice: "Услуга выполнена."
  rescue WorkOrder::TransitionError => e
    redirect_to my_task_path(@line), alert: e.message
  end

  def attach_photos
    authorize @line, :attach_photos?
    files = Array(params.dig(:work_order_service, :photos)).compact_blank
    if files.empty?
      redirect_to my_task_path(@line), alert: "Выберите файл."
      return
    end
    @line.attach_photos!(files)
    redirect_to my_task_path(@line), notice: "Фото добавлены."
  rescue ActiveRecord::RecordInvalid
    redirect_to my_task_path(@line), alert: @line.errors.full_messages.to_sentence
  end

  def purge_photo
    authorize @line, :attach_photos?
    photo = @line.photos.find(params[:photo_id])
    photo.purge
    redirect_to my_task_path(@line), notice: "Фото удалено."
  end

  private

  def set_line
    @line = policy_scope(WorkOrderService).find(params[:id])
  end

  def apply_period_filter(scope)
    from = parse_date(params[:from])
    to = parse_date(params[:to])
    return scope unless from || to

    if from
      scope = scope.where(
        "COALESCE(work_order_services.completed_at, work_order_services.started_at, work_order_services.created_at) >= ?",
        from.beginning_of_day
      )
    end
    if to
      scope = scope.where(
        "COALESCE(work_order_services.completed_at, work_order_services.started_at, work_order_services.created_at) <= ?",
        to.end_of_day
      )
    end
    scope
  end

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
