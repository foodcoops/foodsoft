module FoodsoftActiveJobArguments
  def self.included(base) # :nodoc:
    base.class_eval do
      alias_method :orig_deserialize, :deserialize
      alias_method :orig_serialize, :serialize

      def serialize(arguments)
        ret = orig_serialize(arguments)
        ret.unshift FoodsoftConfig.scope
      end

      def deserialize(arguments)
        FoodsoftConfig.select_multifoodcoop arguments[0]
        orig_deserialize(arguments)
      end

    end
  end
end

module ActiveJob
  module Execution
    # Store the original `_perform_job` method
    original_perform_job = instance_method(:_perform_job)

    # Override the `_perform_job` method
    define_method(:_perform_job) do
      foodsoft_scope = @arguments.shift
      FoodsoftConfig.select_foodcoop foodsoft_scope if FoodsoftConfig[:multi_coop_install]

      # Call the original `_perform_job` method
      original_perform_job.bind(self).call
    end
  end
end


ActiveSupport.on_load(:after_initialize) do
  ActiveJob::Arguments.include FoodsoftActiveJobArguments
end
