class ApplicationJob < ActiveJob::Base
  def serialize
    super.merge(foodcoop: FoodsoftConfig.scope)
  end

  def deserialize(job_data)
    FoodsoftConfig.select_multifoodcoop job_data['foodcoop']
    super(job_data)
  end
end
