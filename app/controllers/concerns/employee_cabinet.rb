# frozen_string_literal: true

module EmployeeCabinet
  extend ActiveSupport::Concern

  included do
    before_action :require_employee!
  end

  private

  def require_employee!
    return if current_user&.employee?

    redirect_to root_path, alert: "Раздел доступен только сотрудникам."
  end
end
