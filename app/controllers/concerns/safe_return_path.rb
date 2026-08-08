# frozen_string_literal: true

# Allows only relative same-origin paths from params[:return_to]
# (blocks open redirects / javascript: / protocol-relative URLs).
module SafeReturnPath
  extend ActiveSupport::Concern

  private

  def safe_return_to(fallback)
    path = params[:return_to].to_s
    return fallback if path.blank?
    return fallback unless path.start_with?("/") && !path.start_with?("//", "/\\")

    path
  end
end
