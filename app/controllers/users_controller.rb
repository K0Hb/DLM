class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def index
    authorize User
    @users = policy_scope(User).order(:email)
  end

  def show
    authorize @user
    all_lines = @user.assigned_work_order_services
    @status_counts = WorkOrderService::STATUSES.index_with { |status| all_lines.where(status: status).count }
    @pool_services = @user.services.order(:name) if @user.employee?

    scope = all_lines.includes(:service, work_order: %i[patient customer])
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(technician_paid: true) if params[:paid] == "yes"
    scope = scope.where(technician_paid: false) if params[:paid] == "no"
    scope = apply_period_filter(scope)
    @completed_sum = scope.where(status: "completed").sum(Arel.sql("quantity * technician_price_snapshot"))
    @paid_sum = scope.where(technician_paid: true).sum(Arel.sql("quantity * technician_price_snapshot"))
    @unpaid_sum = scope.where(technician_paid: false).sum(Arel.sql("quantity * technician_price_snapshot"))
    @lines = scope.order(updated_at: :desc)
  end

  def new
    @user = User.new(role: "employee", active: true)
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to users_path, notice: "Пользователь создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    attrs = user_params
    if attrs[:password].blank?
      attrs = attrs.except(:password, :password_confirmation)
    end

    if @user.update(attrs)
      redirect_to users_path, notice: "Пользователь обновлён."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :full_name, :role, :active, :password, :password_confirmation).tap do |attrs|
      attrs[:role] = "employee" unless current_user.superadmin?
    end
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
