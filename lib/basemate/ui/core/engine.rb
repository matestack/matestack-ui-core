module Basemate
  module Ui
    module Core
      class Engine < ::Rails::Engine
        isolate_namespace Basemate::Ui::Core

        def self.activate
          # Dir.glob(File.join(Rails.root, 'app/basemate/**/*.rb')) do |c|
          #   Rails.configuration.cache_classes ? require(c) : load(c)
          # end
          # Rails.configuration.autoload_paths << Dir.glob(File.join(Rails.root, 'config/basemate/**/*.rb'))
          # require_dependency "#{Rails.root}/config/basemate-ui-core"
        end

        config.to_prepare &method(:activate).to_proc
      end
    end
  end
end
