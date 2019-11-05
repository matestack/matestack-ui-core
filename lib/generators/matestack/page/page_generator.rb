module Matestack
  module Generators
    class PageGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      class_option :app_name, type: :string, required: true
      class_option :namespace, type: :string
      class_option :controller_action, type: :string
      class_option :called_by_app_generator, type: :boolean, default: false

      def app_name
        options[:app_name]
      end

      def namespace
        options[:namespace]
      end

      def controller_action
        if options[:controller_action].nil?
          "#{app_name}\##{file_name}"
        else
          options[:controller_action]
        end
      end

      def create_page
        template "app/matestack/pages/%app_name%/%namespace%/%file_name%.rb"

        unless options[:called_by_app_generator]
          if namespace
            route %{get '#{app_name}/#{namespace}/#{file_name}', to: '#{controller_action}'}
          else
            route %{get '#{app_name}/#{file_name}', to: '#{controller_action}'}
          end

          puts "Page created! Make sure to add"
          puts ""
          puts "def #{file_name}"

          if namespace
            puts "  responder_for(Pages::#{app_name.camelize}::#{namespace.camelize}::#{file_name.camelize})"
          else
            puts "  responder_for(Pages::#{app_name.camelize}::#{file_name.camelize})"
          end

          puts "end"
          puts ""
          puts "to the desired controller!"
        end
      end
    end
  end
end
