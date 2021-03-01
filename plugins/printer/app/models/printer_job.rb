class PrinterJob < ActiveRecord::Base
  belongs_to :order
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_user_id'
  belongs_to :finished_by, optional: true, class_name: 'User', foreign_key: 'finished_by_user_id'
  has_many :printer_job_updates

  scope :finished, -> { where.not(finished_at: nil) }
  scope :unfinished, -> { where(finished_at: nil).order(:id) }
  scope :pending, -> { unfinished.includes(:order).where.not(orders: { state: 'open' }) }
  scope :queued, -> { unfinished.includes(:order).where(orders: { state: 'open' }) }

  def last_update_at
    printer_job_updates.order(:created_at).last.try(&:created_at)
  end

  def last_update_state
    printer_job_updates.order(:created_at).last.try(&:state)
  end

  def add_update!(state, message = nil)
    return unless finished_at.nil?

    PrinterJobUpdate.create! printer_job: self, state: state, message: message
  end

  def finish!(user = nil)
    return unless finished_at.nil?

    update_attributes finished_at: Time.now, finished_by: user
  end
end
