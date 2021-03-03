module Matestack
  module Ui
    module VueJs
      class Vue < Matestack::Ui::Component
        
        def create_children(&block)
          vue_component do
            self.response do
              block.call
            end
          end
        end
        
        def vue_component(&block)
          Matestack::Ui::Core::Base.new(:component, component_attributes, &block)
        end
        
        def component_attributes
          options.merge({
            is: vue_name,
            ref: options[:id] || nil,
            ':params': params.to_json,
            ':component-config': self.config.to_json,
            'inline-template': true
          })
        end
          
        def config
          raise "config needs to be overwritten by #{self.class}"
        end
        
        def self.vue_name(name = nil)
          name ? @vue_name = name : @vue_name
        end
        
        def vue_name
          raise "vue_name missing for #{self.class}" unless self.class.vue_name
          self.class.vue_name
        end

        def self.inherited(subclass)
          subclass.vue_name(self.vue_name)
          super
        end
          
      end
    end
  end
end