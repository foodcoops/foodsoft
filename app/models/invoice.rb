class Invoice < ApplicationRecord
  include CustomFields

  belongs_to :supplier
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_user_id'
  belongs_to :financial_link, optional: true
  has_many :deliveries, dependent: :nullify
  has_many :orders, dependent: :nullify

  validates_presence_of :supplier_id
  validates_numericality_of :amount, :deposit, :deposit_credit
  validate :valid_attachment

  scope :unpaid, -> { where(paid_on: nil) }
  scope :without_financial_link, -> { where(financial_link: nil) }

  attr_accessor :delete_attachment

  # Replace numeric seperator with database format
  localize_input_of :amount, :deposit, :deposit_credit

  def attachment=(incoming_file)
    self.attachment_data = incoming_file.read
    # allow to soft-fail when FileMagic isn't present and removed from Gemfile (e.g. Heroku)
    self.attachment_mime = defined?(FileMagic) ? FileMagic.new(FileMagic::MAGIC_MIME).buffer(self.attachment_data) : 'application/octet-stream'
  end

  def delete_attachment=(value)
    if value == '1'
      self.attachment_data = nil
      self.attachment_mime = nil
    end
  end

  def user_can_edit?(user)
    user.role_finance? || (user.role_invoices? && !self.paid_on && self.created_by.try(:id) == user.id)
  end

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end

  protected

  def valid_attachment
    if attachment_data
      mime = MIME::Type.simplified(attachment_mime)
      unless ['application/pdf', 'image/jpeg'].include? mime
        errors.add :attachment, I18n.t('model.invoice.invalid_mime', :mime => mime)
      end
    end
  end
end
