# frozen_string_literal: true

module Paginates
  extend ActiveSupport::Concern

  private

  # Paginates a relation, assigns @pagination, returns the page records.
  def paginate(scope, per_page: Pagination::DEFAULT_PER_PAGE)
    page = params[:page].to_i
    page = 1 if page < 1
    per_page = per_page.to_i
    per_page = Pagination::DEFAULT_PER_PAGE if per_page < 1

    total_count = pagination_count(scope)
    total_pages = [ (total_count.to_f / per_page).ceil, 1 ].max
    page = total_pages if page > total_pages

    records = scope.offset((page - 1) * per_page).limit(per_page)
    @pagination = Pagination.new(
      records: records,
      page: page,
      per_page: per_page,
      total_count: total_count
    )
    records
  end

  def pagination_count(scope)
    rel = scope.except(:select, :order, :includes, :preload, :eager_load, :offset, :limit)
    if rel.joins_values.any? || rel.left_outer_joins_values.any?
      result = rel.reselect(rel.klass.arel_table[rel.klass.primary_key]).distinct.count
    else
      result = rel.count
    end
    result.is_a?(Hash) ? result.length : result
  end
end
