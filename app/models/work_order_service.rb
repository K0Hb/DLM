class WorkOrderService < ApplicationRecord
  include PhotoAttachable
  photo_limit 10

  STATUSES = %w[assigned in_progress completed].freeze

  belongs_to :work_order
  belongs_to :service
  belongs_to :assignee, class_name: "User"
  belongs_to :technician_paid_by, class_name: "User", optional: true
  has_many :payment_events, dependent: :nullify

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :status, inclusion: { in: STATUSES }
  validates :technician_price_snapshot, numericality: { greater_than_or_equal_to: 0 }
  validate :assignee_must_have_service_in_pool, on: :create
  validate :assignee_change_only_when_assigned, on: :update
  validate :work_order_must_be_editable, on: %i[create update]

  before_validation :snapshot_price, on: :create

  def assigned?
    status == "assigned"
  end

  def in_progress?
    status == "in_progress"
  end

  def completed?
    status == "completed"
  end

  def amount
    quantity * technician_price_snapshot
  end

  def payout_locked_for?(user)
    Payments::Applier.technician_locked?(self, actor: user)
  end

  def payout_eligible?
    Payments::Applier.technician_payable?(self)
  end

  def deletable?
    !completed?
  end

  before_destroy :prevent_destroy_if_completed

  def start!(by:)
    raise WorkOrder::TransitionError, "Нельзя" unless assigned?
    authorize_actor!(by)
    update!(status: "in_progress", started_at: Time.current)
    work_order.ensure_in_progress_from_service!
  end

  def complete!(by:)
    raise WorkOrder::TransitionError, "Нельзя" unless in_progress?
    authorize_actor!(by)
    update!(status: "completed", completed_at: Time.current)
  end

  def rollback_to_in_progress!(by:)
    raise WorkOrder::TransitionError, "Только admin" unless by.admin_or_superadmin?
    raise WorkOrder::TransitionError, "Нельзя" unless completed?
    update!(status: "in_progress", completed_at: nil)
  end

  def rollback_to_assigned!(by:)
    raise WorkOrder::TransitionError, "Только admin" unless by.admin_or_superadmin?
    raise WorkOrder::TransitionError, "Нельзя" unless in_progress?
    update!(status: "assigned", started_at: nil, completed_at: nil)
  end

  private

  def snapshot_price
    self.technician_price_snapshot ||= service&.technician_price
  end

  def assignee_must_have_service_in_pool
    return if assignee.blank? || service.blank?
    return if assignee.services.exists?(service.id)

    errors.add(:assignee_id, "не имеет услугу в пуле")
  end

  def assignee_change_only_when_assigned
    return unless will_save_change_to_assignee_id?
    return if status == "assigned"

    errors.add(:assignee_id, "можно менять только в статусе assigned")
  end

  def work_order_must_be_editable
    return if work_order.blank? || work_order.editable_structure?

    errors.add(:base, "закрытый наряд нельзя менять")
  end

  def authorize_actor!(by)
    return if by.admin_or_superadmin? || by.id == assignee_id

    raise WorkOrder::TransitionError, "Нет прав"
  end

  def prevent_destroy_if_completed
    return unless completed?

    errors.add(:base, "Выполненную услугу нельзя удалить")
    throw :abort
  end
end
