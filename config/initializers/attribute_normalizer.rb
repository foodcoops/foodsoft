# config/initializers/attribute_normalizer.rb
# @see https://github.com/mdeering/attribute_normalizer
AttributeNormalizer.configure do |config|
  # The default normalizers if no :with option or block is given is to apply the :strip and :blank normalizers (in that order).
  # You can change this if you would like as follows:
  # config.default_normalizers = :strip, :blank

  # You can enable the attribute normalizers automatically if the specified attributes exist in your column_names. It will use
  # the default normalizers for each attribute (e.g. config.default_normalizers)
  # config.default_attributes = :name, :title
end
