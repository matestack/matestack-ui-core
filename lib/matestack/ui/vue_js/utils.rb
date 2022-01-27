module Matestack
  module Ui
    module VueJs
      module Utils

        def self.included(base)
          base.extend(ClassMethods)
        end
        module ClassMethods
          def vue_name(name = nil)
            name ? @vue_name = name : @vue_name
          end

          def inherited(subclass)
            subclass.vue_name(self.vue_name)
            super
          end
        end

        def vue_component(&block)
          Matestack::Ui::Core::Base.new(:component, component_attributes) do
            Matestack::Ui::Core::Base.new("matestack-component-template", 'id': "uid-#{component_uid}") do
              yield
            end
          end
        end

        def component_attributes
          {
            is: vue_name,
            ref: component_id,
            ':params': params.to_json,
            ':props': base_vue_props.merge(vue_props)&.to_json,
            'v-slot': "{ vc }"
          }
        end

        def component_id
          options[:id] || nil
        end

        def component_uid
          @component_uid ||= SecureRandom.hex
        end

        def base_vue_props
          { component_uid: component_uid }
        end

        def vue_props
          {} # can be overwritten in sub class
        end
        alias :config :vue_props

        def scoped_ref(value)
          return "#{component_uid}-#{value}" unless value.nil?
        end

        def vue_name
          raise "vue_name missing for #{self.class}" unless self.class.vue_name
          self.class.vue_name
        end

      end
    end
  end
end
