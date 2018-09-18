class Search < OpenStruct
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::AttributeMethods

  validate :atleast_one_search_field_provided?

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 12

  def initialize attrs={}
    super
  end

  def atleast_one_search_field_provided?
    unless (keyword.present? || category.present? || point_range_value.present? || parent_category.present?)
      errors.add(:search, "atleast one parameter should be present")
    end
  end

  def persisted?
    false
  end

  def per_page_value
    per_page || DEFAULT_PER_PAGE
  end

  def page_value
    page || DEFAULT_PAGE
  end

  def point_range_value
    point_range_min..point_range_max if point_range_min.present? && point_range_max.present?
  end

  def for_stats(attr)
    attrs = self.marshal_dump
    attrs[:point_range_min] = nil
    attrs[:point_range_max] = nil
    attrs[:per_page] = 0
    attrs[:stats]= attr
    Search.new(attrs)
  end
end