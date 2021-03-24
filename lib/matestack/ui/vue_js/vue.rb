module Matestack
  module Ui
    module VueJs
      class Vue < Matestack::Ui::Component

        def initialize(html_tag = nil, text = nil, options = {}, &block)
          extract_options(text, options)
          super(html_tag, text, options, &block)
        end
        
        def create_children(&block)
          vue_component do
            self.response do
              block.call if block_given?
            end
          end
        end
        
        def vue_component(&block)
          Matestack::Ui::Core::Base.new(:component, component_attributes, &block)
        end
        
        def component_attributes
          {
            is: vue_name,
            ref: component_id,
            ':params': params.to_json,
            ':component-config': self.config.to_json,
            'inline-template': true
          }
        end

        def component_id
          options[:id] || nil
        end
          
        def config
          # raise "config needs to be overwritten by #{self.class}"
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