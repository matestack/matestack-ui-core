# This migration comes from active_storage (originally 20190112182829)
if Rails::VERSION::MAJOR >= 6 && Rails::VERSION::MINOR >= 1
  class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[6.0]
    def up
      unless column_exists?(:active_storage_blobs, :service_name)
        add_column :active_storage_blobs, :service_name, :string

        if configured_service = ActiveStorage::Blob.service.name
          ActiveStorage::Blob.unscoped.update_all(service_name: configured_service)
        end

        change_column :active_storage_blobs, :service_name, :string, null: false
      end
    end

    def down
      remove_column :active_storage_blobs, :service_name
    end
  end
else
  class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[5.2]
    def up

    end

    def down

    end
  end
end
