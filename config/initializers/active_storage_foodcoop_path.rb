require 'active_storage/service/disk_service'

module FoodsoftActiveStorageDiskController
  def self.included(base) # :nodoc:
    base.class_eval do
      def show
        if key = decode_verified_key
          FoodsoftConfig.select_foodcoop(key[:scope])
          serve_file named_disk_service(key[:service_name]).path_for(key[:key]), content_type: key[:content_type], disposition: key[:disposition]
        else
          head :not_found
        end
      rescue Errno::ENOENT
        head :not_found
      end
    end
  end
end

module FoodsoftActiveStorageDiskService
  def self.included(base) # :nodoc:
    base.class_eval do
      def path_for(key)
        File.join root, FoodsoftConfig.scope, folder_for(key), key
      end

      def generate_url(key, expires_in:, filename:, content_type:, disposition:)
        content_disposition = content_disposition_with(type: disposition, filename: filename)
        verified_key_with_expiration = ActiveStorage.verifier.generate(
          {
            key: key,
            scope: FoodsoftConfig.scope,
            disposition: content_disposition,
            content_type: content_type,
            service_name: name
          },
          expires_in: expires_in,
          purpose: :blob_key
        )

        raise ArgumentError, "Cannot generate URL for #{filename} using Disk service, please set ActiveStorage::Current.url_options." if url_options.blank?

        url_helpers.rails_disk_service_url(verified_key_with_expiration, filename: filename, **url_options)
      end
    end
  end
end

ActiveSupport.on_load(:after_initialize) do
  ActiveStorage::Service::DiskService.include FoodsoftActiveStorageDiskService
  ActiveStorage::DiskController.include FoodsoftActiveStorageDiskController
end
