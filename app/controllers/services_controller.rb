class ServicesController < ApplicationController
  include CatalogCrud

  def destroy
    authorize @record
    @record.destroy!
    redirect_to polymorphic_path(model_class), notice: "#{model_label}: удалено."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to @record, alert: "Нельзя удалить: услуга используется в нарядах."
  end

  private

  def model_class
    Service
  end

  def model_label
    "Услуга"
  end

  def order_column
    :name
  end

  def record_params
    params.require(:service).permit(:name, :description, :technician_price, :active)
  end

  def default_attrs
    { active: true, technician_price: 0 }
  end

  def after_save_path
    @record
  end
end
