module Matestack
  module Generators
    class ComponentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      class_option :dynamic, type: :boolean, default: false
      class_option :scss, type: :boolean, default: false
      class_option :haml, type: :boolean, default: false
      class_option :namespace, type: :string

      def namespace
        options[:namespace]
      end

      def dynamic
        options[:dynamic]
      end

      def create_component
        # Future: Check for matestack-compatible namespacing!

        template 'app/matestack/components/%namespace%/%file_name%.rb.tt'
        template 'app/matestack/components/%namespace%/%file_name%.js.tt' if options[:dynamic]
        template 'app/matestack/components/%namespace%/%file_name%.scss.tt' if options[:scss]
        template 'app/matestack/components/%namespace%/%file_name%.haml.tt' if options[:haml]
      end
    end
  end
end
