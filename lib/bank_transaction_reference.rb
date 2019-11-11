class BankTransactionReference

  # parses a string from a bank transaction field
  def self.parse(data)
    m = /(^|\s)FS(?<group>\d+)(\.(?<user>\d+))?(?<parts>([A-Za-z]+\d+(\.\d+)?)+)(\s|$)/.match(data)
    return unless m

    parts = {}
    m[:parts].scan(/([A-Za-z]+)(\d+(\.\d+)?)/) do |category, value|
      value = value.to_f
      value += parts[category] if parts[category]
      parts[category] = value
    end

    ret = { group: m[:group], parts: parts }
    ret[:user] = m[:user] if m[:user]
    return ret
  end

  def self.js_code_for_user(user)
    %{
      function(items) {
        var ret = "FS#{user.ordergroup.id}.#{user.id}";
        for (var key in items) {
          if (items.hasOwnProperty(key)) {
            ret += key + items[key];
          }
        }
        return ret;
      }
    }
  end

end
