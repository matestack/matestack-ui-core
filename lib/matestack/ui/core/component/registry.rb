module Matestack::Ui::Core::Component
  # Central Registration point for all component DSL methods.
  #
  # Keeps track of currently registered DSL methods to warn on
  # conflicts. Adds them to a specified DSL module.
  #
  # Functions as a singleton as we don't want to have methods
  # meaning something different within the same application.
  #
  # TODO: Potentially all DSL methods to further avoid conflicts?
  module Registry
    DEFAULT_DSL_MODULE = Matestack::Ui::Core::DSL

    module_function

    def register_component(dsl_name, component_class)
      instance.register_component(dsl_name, component_class)
    end

    def register_components(components_hash)
      components_hash.each do |dsl_name, component_class|
        register_component dsl_name, component_class
      end
    end

    def instance(target_module = DEFAULT_DSL_MODULE)
      @instance ||= Instance.new(target_module)
    end

    class Instance

      attr_reader :target_module, :registered_components

      def initialize(target_module)
        @target_module = target_module
        @registered_components = {}
      end

      def register_component(dsl_name, component_class)
        target_module.define_method(dsl_name) do |*args, &block|
          add_child component_class, *args, &block
        end
        registered_components[dsl_name] = component_class
      end
    end
  end
end
