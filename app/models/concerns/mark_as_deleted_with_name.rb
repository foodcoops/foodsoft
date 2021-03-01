module MarkAsDeletedWithName
  extend ActiveSupport::Concern

  def mark_as_deleted
    # get maximum length of name
    max_length = 100000
    if lenval = self.class.validators_on(:name).detect { |v| v.is_a?(ActiveModel::Validations::LengthValidator) }
      max_length = lenval.options[:maximum]
    end
    # find unique deleted name
    # (would have been nice to use retry, but there is no general duplicate-entry exception)
    n = ''
    begin
      append = " \u2020" + n
      deleted_name = name.truncate(max_length - append.length, omission: '') + append
      if n.blank?
        n = 'A'
      else
        n.succ!
      end
    end while self.class.where(name: deleted_name).exists?
    # mark as deleted
    update_columns deleted_at: Time.now, name: deleted_name
  end
end
