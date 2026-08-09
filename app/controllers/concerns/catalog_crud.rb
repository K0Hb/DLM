module CatalogCrud
  extend ActiveSupport::Concern

  included do
    before_action :set_record, only: %i[show edit update destroy]
  end

  def index
    authorize model_class
    @records = paginate(policy_scope(model_class).order(order_column))
  end

  def show
    authorize @record
  end

  def new
    @record = model_class.new(default_attrs)
    authorize @record
  end

  def create
    @record = model_class.new(record_params)
    authorize @record
    if @record.save
      redirect_to after_save_path, notice: "#{model_label}: сохранено."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @record
  end

  def update
    authorize @record
    if @record.update(record_params)
      redirect_to after_save_path, notice: "#{model_label}: сохранено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @record
    @record.destroy!
    redirect_to polymorphic_path(model_class), notice: "#{model_label}: удалено."
  end

  private

  def set_record
    @record = model_class.find(params[:id])
  end

  def default_attrs
    {}
  end

  def order_column
    :id
  end

  def after_save_path
    polymorphic_path(model_class)
  end
end
