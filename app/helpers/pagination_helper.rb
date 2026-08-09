# frozen_string_literal: true

module PaginationHelper
  def pagination_url(page)
    url_for(request.query_parameters.merge("page" => page))
  end

  def render_pagination(pagination = @pagination)
    return if pagination.blank?

    render "shared/pagination", pagination: pagination
  end
end
