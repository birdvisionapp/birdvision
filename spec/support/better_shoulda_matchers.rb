module BetterShouldaMatchers
  def validate_presence_of(attr)
    Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher.new(attr).with_message(/.*/)
  end
  def validate_uniqueness_of(attr)
    Shoulda::Matchers::ActiveModel::ValidateUniquenessOfMatcher.new(attr).with_message(/.*/)
  end
  def validate_numericality_of(attr)
    Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher.new(attr).with_message(/.*/)
  end
  def ensure_length_of(attr)
    Shoulda::Matchers::ActiveModel::EnsureLengthOfMatcher.new(attr).with_message(/.*/)
  end
  def validate_format_of(attr)
    Shoulda::Matchers::ActiveModel::ValidateFormatOfMatcher.new(attr).with_message(/.*/)
  end
  def validate_confirmation_of(attr)
    Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher.new(attr).with_message(/.*/)
  end
end