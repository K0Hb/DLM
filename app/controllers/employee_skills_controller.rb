class EmployeeSkillsController < ApplicationController
  before_action :set_employee, only: %i[edit update]

  def index
    authorize User, :index?, policy_class: EmployeeSkillPolicy
    @employees = User.employees.order(:full_name)
  end

  def edit
    authorize @employee, :edit?, policy_class: EmployeeSkillPolicy
    @services = Service.order(:name)
  end

  def update
    authorize @employee, :update?, policy_class: EmployeeSkillPolicy
    service_ids = Array(params.dig(:user, :service_ids)).reject(&:blank?)
    @employee.service_ids = service_ids
    redirect_to employee_skills_path, notice: "Пул услуг обновлён."
  end

  private

  def set_employee
    @employee = User.employees.find(params[:id])
  end
end
