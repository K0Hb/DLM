module PhotoAttachable
  extend ActiveSupport::Concern

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_BYTE_SIZE = 10.megabytes

  class_methods do
    def photo_limit(limit)
      @photo_limit = limit
    end

    def photos_limit
      @photo_limit || 10
    end
  end

  included do
    has_many_attached :photos
    validate :photos_must_meet_limits
  end

  def attach_photos!(files)
    files = Array(files).compact_blank
    raise ActiveRecord::RecordInvalid, tap { errors.add(:photos, "выберите файл") } if files.empty?

    if photos.count + files.size > self.class.photos_limit
      errors.add(:photos, "не больше #{self.class.photos_limit} файлов")
      raise ActiveRecord::RecordInvalid, self
    end

    files.each do |file|
      validate_upload_file!(file)
      photos.attach(file)
    end

    raise ActiveRecord::RecordInvalid, self unless valid?
  end

  private

  def validate_upload_file!(file)
    content_type = file.content_type.to_s
    size = file.size.to_i

    unless ALLOWED_CONTENT_TYPES.include?(content_type)
      errors.add(:photos, "допустимы только JPEG, PNG, WebP")
      raise ActiveRecord::RecordInvalid, self
    end
    return unless size > MAX_BYTE_SIZE

    errors.add(:photos, "каждый файл не больше 10 МБ")
    raise ActiveRecord::RecordInvalid, self
  end

  def photos_must_meet_limits
    return unless photos.attached?

    if photos.count > self.class.photos_limit
      errors.add(:photos, "не больше #{self.class.photos_limit} файлов")
    end

    photos.each do |photo|
      blob = photo.blob
      next unless blob

      unless ALLOWED_CONTENT_TYPES.include?(blob.content_type)
        errors.add(:photos, "допустимы только JPEG, PNG, WebP")
      end
      if blob.byte_size > MAX_BYTE_SIZE
        errors.add(:photos, "каждый файл не больше 10 МБ")
      end
    end
  end
end
