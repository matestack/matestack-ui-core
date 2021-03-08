module Matestack
  module Ui
    module VueJs
      class Vue < Matestack::Ui::Component

        def initialize(html_tag = nil, text = nil, options = {}, &block)
          extract_options(text, options)
          create_internal_context
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
          options.merge({
            is: vue_name,
            ref: component_id,
            ':params': params.to_json,
            ':component-config': self.config.to_json,
            'inline-template': true
          })
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

        # implementing a internal context which allows to specify options which will be deleted from the options hash
        # and can be accessed inside a vue component scope

        def internal_context
          @internal_context ||= OpenStruct.new
        end

        def self.internal(*args)
          @internal = (@internal || []).concat(args)
        end

        def self.internal_options
          @internal
        end

        def internal_options
          self.class.internal_options || []
        end

        def create_internal_context
          self.internal_options.uniq.each do |option|
            if option.is_a?(Hash)
              option.each do |key, value|
                method_name = value[:as] || key
                required = value[:required]
                internal_context.send(:"#{method_name}=", self.options.delete(key))
                raise "required option '#{key}' is missing for #{self}" if internal_context.send(method_name).nil? && required
              end
            else
              internal_context.send(:"#{option}=", self.options.delete(option))
            end
          end
        end
          
      end
    end
  end
end