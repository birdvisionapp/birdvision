class LessThanEqualToValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    other_attribute = record.send(options[:attribute])
    return if value.nil? || other_attribute.nil?

    if (options[:allow_equal])
      if (value > other_attribute)
      add_error(attribute, record)
      end
    else
      if (value >= other_attribute)
      add_error(attribute, record)
      end
    end
  end

  private
  def add_error(attribute, record)
    record.errors.add(attribute, :less_than_equal_to_other, options.merge(:other => record.class.human_attribute_name(options[:attribute])))
  end
end