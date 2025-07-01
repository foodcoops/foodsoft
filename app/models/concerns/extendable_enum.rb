module ExtendableEnum
  extend ActiveSupport::Concern

  class ExtendableEnumType < ActiveRecord::Enum::EnumType
    def add_value(value)
      @mapping[value] = value.to_s
    end

    def values
      @mapping.freeze
    end
  end

  class_methods do
    def extendable_enum(name, values)
      enum_type = ExtendableEnumType.new(name, values, ActiveModel::Type::String.new)
      attribute name, enum_type

      define_singleton_method("add_#{name}_value") do |value|
        enum_type.add_value(value)
      end

      define_singleton_method("#{name}s") do
        enum_type.values
      end
    end
  end
end
