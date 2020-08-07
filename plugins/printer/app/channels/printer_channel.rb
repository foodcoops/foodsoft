class PrinterChannel < ApplicationCable::Channel
  def subscribed
    stream_from self.class.broadcasting
    self.class.broadcast_unfinished
  end

  def update(data)
    job = PrinterJob.unfinished.find_by_id(data['id'])
    return unless job

    job.add_update! data['state'], data['message'] if data['state']
    job.finish! if data['finish']
    self.class.broadcast_unfinished
  end

  def self.broadcast_unfinished
    ActionCable.server.broadcast(broadcasting, {
                                   unfinished_job_ids: PrinterJob.pending.pluck(:id)
                                 })
  end
end
