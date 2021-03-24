require 'active_storage/service/disk_service'

module FoodsoftActiveStorageDiskService
  def self.included(base) # :nodoc:
    base.class_eval do
      def path_for(key)
        File.join root, FoodsoftConfig.scope, folder_for(key), key
      end
    end
  end
end

ActiveSupport.on_load(:after_initialize) do
  ActiveStorage::Service::DiskService.include FoodsoftActiveStorageDiskService
end
