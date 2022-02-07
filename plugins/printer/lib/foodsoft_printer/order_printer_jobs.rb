module FoodsoftPrinter
  module OrderPrinterJobs
    def self.included(base) # :nodoc:
      base.class_eval do
        has_many :printer_jobs, dependent: :destroy

        alias foodsoft_printer_orig_finish! finish!

        def finish!(user)
          foodsoft_printer_orig_finish!(user)
          unless finished?
            printer_jobs.unfinished.each do |job|
              job.add_update! 'ready'
            end
          end
        end
      end
    end

    def self.install
      Order.send :include, self
    end
  end
end
