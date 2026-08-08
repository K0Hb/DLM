class WorkOrdersController < ApplicationController
  before_action :set_work_order, only: %i[show edit update destroy advance rollback attach_photos purge_photo]

  def index
    authorize WorkOrder
    @work_orders = policy_scope(WorkOrder).includes(:customer, :patient).order(number: :desc)
    @work_orders = @work_orders.where(status: params[:status]) if params[:status].present?
    @work_orders = @work_orders.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    if params[:paid] == "yes"
      @work_orders = @work_orders.where("customer_paid_amount > 0")
    elsif params[:paid] == "no"
      @work_orders = @work_orders.where(customer_paid_amount: 0)
    end
    if params[:patient].to_s.strip.present?
      q = "%#{params[:patient].to_s.strip}%"
      @work_orders = @work_orders.left_joins(:patient).where("patients.full_name ILIKE ?", q)
    end
  end

  def show
    authorize @work_order
    @manage_work_order = policy(@work_order).update?
    @line = WorkOrderService.new(work_order: @work_order)
    @services = Service.where(active: true).order(:name)
    @employees = User.employees.active_users.order(:full_name)
    @employee_ids_by_service = Service.where(active: true).includes(:users).each_with_object({}) do |service, map|
      map[service.id] = service.users.select { |u| u.employee? && u.active? }.map(&:id)
    end
  end

  def new
    @work_order = WorkOrder.new(dental_formula: Odontogram.empty)
    authorize @work_order
    load_form_collections
  end

  def create
    @work_order = WorkOrder.new(work_order_params)
    @work_order.created_by = current_user
    authorize @work_order
    assign_inline_patient!(@work_order)

    if @work_order.errors.empty? && @work_order.save
      redirect_to @work_order, notice: "Наряд создан."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @work_order
    load_form_collections
  end

  def update
    authorize @work_order
    @work_order.assign_attributes(work_order_params)
    assign_inline_patient!(@work_order)

    if @work_order.errors.empty? && @work_order.save
      redirect_to @work_order, notice: "Наряд обновлён."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @work_order
    if @work_order.draft? && current_user.superadmin?
      @work_order.destroy!
      redirect_to work_orders_path, notice: "Наряд удалён."
    else
      redirect_to @work_order, alert: "Удалять можно только черновик (superadmin)."
    end
  end

  def advance
    authorize @work_order, :update?
    @work_order.advance_to!(params.require(:to), by: current_user)
    redirect_to @work_order, notice: "Статус обновлён."
  rescue WorkOrder::TransitionError => e
    redirect_to @work_order, alert: e.message
  end

  def rollback
    authorize @work_order, :update?
    @work_order.rollback_to!(params.require(:to), by: current_user)
    redirect_to @work_order, notice: "Откат выполнен."
  rescue WorkOrder::TransitionError => e
    redirect_to @work_order, alert: e.message
  end

  def attach_photos
    authorize @work_order, :update?
    files = Array(params.dig(:work_order, :photos)).compact_blank
    if files.empty?
      redirect_to @work_order, alert: "Выберите файл."
      return
    end
    @work_order.attach_photos!(files)
    redirect_to @work_order, notice: "Фото добавлены."
  rescue ActiveRecord::RecordInvalid
    redirect_to @work_order, alert: @work_order.errors.full_messages.to_sentence
  end

  def purge_photo
    authorize @work_order, :update?
    photo = @work_order.photos.find(params[:photo_id])
    photo.purge
    redirect_to @work_order, notice: "Фото удалено."
  end

  private

  def set_work_order
    @work_order = WorkOrder.includes(work_order_services: %i[service assignee]).find(params[:id])
  end

  def load_form_collections
    @customers = Customer.where(active: true).order(:name)
    @doctors = Doctor.where(active: true).order(:full_name)
    @patients = Patient.includes(:doctor).order(:full_name)
  end

  def assign_inline_patient!(work_order)
    name = params[:new_patient_full_name].to_s.strip
    return if name.blank?

    doctor_id = work_order.doctor_id.presence || params[:new_patient_doctor_id].presence
    if doctor_id.blank?
      work_order.errors.add(:base, "Для нового пациента укажите врача")
      return
    end

    patient = Patient.create(full_name: name, doctor_id: doctor_id)
    if patient.persisted?
      work_order.patient = patient
      work_order.doctor_id ||= patient.doctor_id
    else
      work_order.errors.add(:base, "Не удалось создать пациента: #{patient.errors.full_messages.to_sentence}")
    end
  end

  def work_order_params
    params.require(:work_order).permit(
      :customer_id, :doctor_id, :patient_id, :due_at, :notes, :tooth_color, :material_note,
      :customer_payment_amount, :dental_formula,
      dental_formula: [ :notation, :shade, { teeth: [ :n, :type, :shade ], connectors: [] } ]
    ).tap do |p|
      if p[:dental_formula].is_a?(String)
        p[:dental_formula] = JSON.parse(p[:dental_formula]) rescue Odontogram.empty
      end
      p[:patient_id] = nil if p[:patient_id].blank?
      p[:doctor_id] = nil if p[:doctor_id].blank?
    end
  end
end
