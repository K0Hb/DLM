class PublicOrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @work_order = WorkOrder.includes(:customer, :doctor, :patient, work_order_services: %i[service assignee])
      .find_by!(public_token: params[:public_token])
  end
end
