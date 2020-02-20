module Matestack
  module Ui
    module Core
      class Engine < ::Rails::Engine
        isolate_namespace Matestack::Ui::Core

        def self.activate
          # Dir.glob(File.join(Rails.root, 'app/matestack/**/*.rb')) do |c|
          #   Rails.configuration.cache_classes ? require(c) : load(c)
          # end
          # Rails.configuration.autoload_paths << Dir.glob(File.join(Rails.root, 'config/matestack/**/*.rb'))
          # require_dependency "#{Rails.root}/config/matestack-ui-core"

          components_path = "#{Rails.root}/app/matestack/register_components"
          if File.exist?("#{components_path}.rb")
            # the other dependencies need to be loaded otherwise require_dependency crashes silently
            # we don't need to require_dependency them because they don't need reloading
            # anyhow, they should probably be required somewhere else before this anyhow?
            require 'matestack/ui/core/dsl'
            require 'matestack/ui/core/component/registry'
            require_dependency "#{Rails.root}/app/matestack/register_components"
          end
        end

        # config.to_prepare takes a block that should be run to set up
        # your Railtie/Engine. It is run once in production mode and on
        # every request in development, and is the only code guaranteed to
        # be called on every single request in development mode.
        # source: https://stackoverflow.com/a/5109348
        # (couldn't find official docs)
        config.to_prepare &method(:activate).to_proc
      end
    end
  end
end
