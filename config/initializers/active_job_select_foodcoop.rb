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

ActiveSupport.on_load(:after_initialize) do
  ActiveJob::Arguments.include FoodsoftActiveJobArguments
end
