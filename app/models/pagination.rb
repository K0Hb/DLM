# frozen_string_literal: true

class Pagination
  DEFAULT_PER_PAGE = 40
  WINDOW = 2

  attr_reader :records, :page, :per_page, :total_count, :total_pages

  def initialize(records:, page:, per_page:, total_count:)
    @records = records
    @page = page
    @per_page = per_page
    @total_count = total_count
    @total_pages = [ (total_count.to_f / per_page).ceil, 1 ].max
  end

  def offset
    (page - 1) * per_page
  end

  def from
    return 0 if total_count.zero?

    offset + 1
  end

  def to
    [ offset + records.size, total_count ].min
  end

  def prev_page
    page > 1 ? page - 1 : nil
  end

  def next_page
    page < total_pages ? page + 1 : nil
  end

  def pages_to_show
    return [] if total_pages <= 1

    left = [ page - WINDOW, 1 ].max
    right = [ page + WINDOW, total_pages ].min
    pages = []
    pages << 1 if left > 1
    pages << :gap if left > 2
    (left..right).each { |n| pages << n }
    pages << :gap if right < total_pages - 1
    pages << total_pages if right < total_pages
    pages
  end
end
