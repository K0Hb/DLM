class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :services
  has_many :assigned_work_order_services, class_name: "WorkOrderService", foreign_key: :assignee_id, dependent: :restrict_with_error, inverse_of: :assignee

  ROLES = %w[superadmin admin employee].freeze

  validates :full_name, presence: true
  validates :role, presence: true, inclusion: { in: ROLES }

  before_validation :normalize_email

  scope :employees, -> { where(role: "employee") }
  scope :active_users, -> { where(active: true) }

  def superadmin?
    role == "superadmin"
  end

  def admin?
    role == "admin"
  end

  def employee?
    role == "employee"
  end

  def admin_or_superadmin?
    admin? || superadmin?
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :inactive
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
