# handles membership fee processing

module FoodsoftSignup

  module DebitMembership
    def self.included(base) # :nodoc:
      base.class_eval do
        after_create :debit_membership!, :unless => Proc.new { FoodsoftConfig[:membership_fee].nil? }

        def debit_membership!
          amount = (-FoodsoftConfig[:membership_fee]).to_s
          amount.gsub!('\.', I18n.t('separator', :scope => 'number.format')) # workaround localize_input problem
          note = I18n.t('foodsoft_signup.membership_fee.transaction_note')
          # skip notification on negative amount here
          transaction do
            t = FinancialTransaction.new(:ordergroup => self, :amount => amount, :note => note, :user_id => 0)
            t.save!
            self.account_balance = financial_transactions.sum('amount')
            save!
          end
        end
      end
    end
  end

end

ActiveSupport.on_load(:after_initialize) do
  Ordergroup.send :include, FoodsoftSignup::DebitMembership
end
