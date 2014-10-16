# Serializer for ActiveRecord for Array of Symbols.
# @see ActiveRecord::AttributeMethods::Serialization#serialize
class SymbolArraySerializer

  # @param str [String] String to deserialize
  # @return [Array<Symbol>] Array of symbols
  def self.load(str)
    if str
      str.split(/,\s*/).map(&:to_sym)
    else
      []
    end
  end

  # @param arr [Array, Hash] Array to serialize (or Hash for easy form usage)
  # @return [String] Serialized string
  def self.dump(arr)
    if arr
      arr = arr.select{|k,v| v and v!="0"}.keys if arr.is_a? Hash
      arr.join ',' if arr.any?
    end
  end

end
