class WorkOrder < ApplicationRecord
  include PhotoAttachable
  photo_limit 20

  STATUSES = %w[draft in_progress ready sent closed].freeze

  belongs_to :customer
  belongs_to :doctor, optional: true
  belongs_to :patient, optional: true
  belongs_to :created_by, class_name: "User"
  belongs_to :customer_paid_by, class_name: "User", optional: true
  has_many :work_order_services, dependent: :destroy
  has_many :payment_events, dependent: :nullify

  validates :number, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :public_token, presence: true, uniqueness: true
  validates :customer_paid_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :customer_payment_amount, numericality: { greater_than_or_equal_to: 0 }
  validate :dental_formula_must_be_valid
  before_validation :sync_tooth_color_from_formula

  before_validation :assign_defaults, on: :create

  scope :with_status, ->(status) { where(status: status) if status.present? }

  def customer_paid?
    customer_paid_amount.to_d > 0
  end

  def customer_order_payment_amount
    customer_paid? ? customer_paid_amount : customer_payment_amount
  end

  def services_total_amount
    assigned_service_lines.sum { |l| l.quantity * l.technician_price_snapshot }
  end

  def assigned_service_lines
    work_order_services.select { |line| line.persisted? && !line.removed? }
  end

  def editable_structure?
    !closed?
  end

  def draft?
    status == "draft"
  end

  def closed?
    status == "closed"
  end

  def all_services_completed?
    lines = assigned_service_lines
    lines.any? && lines.all?(&:completed?)
  end

  ADVANCE_LABELS = {
    "in_progress" => "В работу",
    "ready" => "Готов",
    "sent" => "Отправлен",
    "closed" => "Закрыт"
  }.freeze

  ROLLBACK_LABELS = {
    "draft" => "Откат в черновик",
    "in_progress" => "Откат в работу",
    "ready" => "Откат в готов"
  }.freeze

  def advance_targets
    case status
    when "draft"
      [ "in_progress" ]
    when "in_progress"
      all_services_completed? && assigned_service_lines.any? ? [ "ready" ] : []
    when "ready"
      [ "sent", "closed" ]
    when "sent"
      [ "closed" ]
    else
      []
    end
  end

  def rollback_targets
    return [] if closed?

    case status
    when "in_progress"
      assigned_service_lines.any? { |s| s.in_progress? || s.completed? } ? [] : [ "draft" ]
    when "ready"
      [ "in_progress" ]
    when "sent"
      [ "ready" ]
    else
      []
    end
  end

  def advance_to!(target, by:)
    case [ status, target ]
    when %w[draft in_progress]
      update!(status: "in_progress")
    when %w[in_progress ready]
      raise TransitionError, "Нужна хотя бы одна выполненная услуга" unless all_services_completed?
      update!(status: "ready")
    when %w[ready sent]
      update!(status: "sent", sent_at: Time.current)
    when %w[ready closed], %w[sent closed]
      raise TransitionError, "Нужна хотя бы одна выполненная услуга" unless all_services_completed?
      update!(status: "closed", closed_at: Time.current)
    else
      raise TransitionError, "Переход #{status} → #{target} запрещён"
    end
  end

  def rollback_to!(target, by:)
    raise TransitionError, "Откат из закрытого наряда запрещён" if closed?

    case [ status, target ]
    when %w[in_progress draft]
      if assigned_service_lines.any? { |s| s.in_progress? || s.completed? }
        raise TransitionError, "Есть услуги в работе или выполненные"
      end
      update!(status: "draft")
    when %w[ready in_progress]
      update!(status: "in_progress")
    when %w[sent ready]
      update!(status: "ready", sent_at: nil)
    else
      raise TransitionError, "Откат #{status} → #{target} запрещён"
    end
  end

  def ensure_in_progress_from_service!
    update!(status: "in_progress") if draft?
  end

  class TransitionError < StandardError; end

  private

  def assign_defaults
    self.number ||= next_number
    self.public_token ||= SecureRandom.urlsafe_base64(24)
    self.dental_formula = Odontogram.normalize(dental_formula.presence || Odontogram.empty)
    self.status ||= "draft"
  end

  def next_number
    self.class.maximum(:number).to_i + 1
  end

  def dental_formula_must_be_valid
    normalized = Odontogram.normalize(dental_formula)
    unless Odontogram.valid?(normalized)
      errors.add(:dental_formula, "некорректна")
      return
    end
    self.dental_formula = normalized
  end

  def sync_tooth_color_from_formula
    data = dental_formula.is_a?(String) ? (JSON.parse(dental_formula) rescue {}) : (dental_formula || {})
    shade = data["shade"].presence || data[:shade].presence
    self.tooth_color = shade
  end
end
