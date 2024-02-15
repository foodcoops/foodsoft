# require File.dirname(__FILE__) + "/../../../../app/models/order"

module FoodsoftPrinter
  module OrderPrinterJobs
    def self.included(base) # :nodoc:
      base.class_eval do
        has_many :printer_jobs, dependent: :destroy

        def printer_finish!(user)
          unless finished?
            printer_jobs.unfinished.each do |job|
              job.add_update! 'ready'
            end
          end
        end
      end
    end

    def self.install
      # ::Order.send :include, self
    end
  end
end
