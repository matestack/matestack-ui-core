# This migration comes from active_storage (originally 20190112182829)
class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def up
    if Rails::VERSION::MAJOR >= 6 && Rails::VERSION::MINOR >= 1
      unless column_exists?(:active_storage_blobs, :service_name)
        add_column :active_storage_blobs, :service_name, :string

        if configured_service = ActiveStorage::Blob.service.name
          ActiveStorage::Blob.unscoped.update_all(service_name: configured_service)
        end

        change_column :active_storage_blobs, :service_name, :string, null: false
      end
    end
  end

  def down
    if Rails::VERSION::MAJOR >= 6 && Rails::VERSION::MINOR >= 1
      remove_column :active_storage_blobs, :service_name
    end
  end
end
