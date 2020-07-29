class BankAccountConnector

  class TextItem
    def initialize(text)
      @text = text
    end

    def name
      nil
    end

    def text
      @text
    end

  end

  class TextField
    def initialize(name, value, label)
      @name = name
      @value = value
      @label = label
    end

    def type
      nil
    end

    def name
      @name
    end

    def value
      @value
    end

    def label
      @label || @name.to_s
    end
  end

  class PasswordField < TextField

    def type
      :password
    end

  end

  class HiddenField < TextField

    def type
      :hidden
    end

  end


  @@registered_classes = Set.new

  def self.register(klass)
    @@registered_classes.add klass
  end

  def self.find(iban)
    @@registered_classes.each do |klass|
      return klass if klass.handles(iban)
    end
    nil
  end

  def initialize(bank_account)
    @bank_account = bank_account
    @auto_submit = nil
    @controls = []
    @count = 0
  end

  def iban
    @bank_account.iban
  end

  def auto_submit
    @auto_submit
  end

  def controls
    @controls
  end

  def count
    @count
  end

  def text(data)
    @controls += [TextItem.new(data)]
  end

  def confirm_text(code)
    text t('.confirm', code: code)
  end

  def wait_with_text(auto_submit, code)
    @auto_submit = auto_submit
    confirm_text code
  end

  def wait_for_app(code)
    hidden_field :twofactor, code
    wait_with_text 3000, code
    nil
  end

  def text_field(name, value=nil)
    @controls += [TextField.new(name, value, t(name))]
  end

  def hidden_field(name, value)
    @controls += [HiddenField.new(name, value, 'HIDDEN')]
  end

  def password_field(name, value=nil)
    @controls += [PasswordField.new(name, value, t(name))]
  end

  def set_balance(amount)
    @bank_account.balance = amount
  end

  def set_balance_as_sum
    @bank_account.balance = @bank_account.bank_transactions.sum(:amount)
  end

  def continuation_point
    @bank_account.import_continuation_point
  end

  def set_continuation_point(data)
    @bank_account.import_continuation_point = data
  end

  def update_or_create_transaction(external_id, data={})
    @bank_account.bank_transactions.where(external_id: external_id).first_or_create.update(data)
    @count += 1
  end

  def finish
    @bank_account.last_import = Time.now
    @bank_account.save!
  end

  def load(data)
  end

  def dump
  end

  def t(key, args={})
    return t(".fields.#{key}") unless key.is_a? String
    I18n.t 'bank_account_connector' + key, args
  end
end
