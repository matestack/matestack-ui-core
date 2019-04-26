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
        end

        config.to_prepare &method(:activate).to_proc
      end
    end
  end
end
