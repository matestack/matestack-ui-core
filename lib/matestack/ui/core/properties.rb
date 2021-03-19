module Matestack
  module Ui
    module Core
      module Properties
        
        def self.included(base)
          base.extend ClassMethods
          base.send :prepend, Initializer
        end
        
        module Initializer
          def initialize(html_tag = nil, text = nil, options = {}, &block)
            extract_options(text, options)
            create_context
            super
          end
        end
        
        module ClassMethods
          extend Gem::Deprecate

          def required(*args)
            @required = (@required || []).concat(args)
          end
          alias requires required
          deprecate :requires, :required, 2021, 10

          def optional(*args)
            @optional = (@optional || []).concat(args)
          end
          
          def required_property_keys
            @required
          end
      
          def optional_property_keys
            @optional
          end

          def inherited(subclass)
            subclass.required(*required_property_keys)
            subclass.optional(*optional_property_keys)
            super
          end
        end
    
        def context 
          @context ||= OpenStruct.new
        end
        alias :ctx :context
        
        def required_property_keys
          self.class.required_property_keys || []
        end
        
        def optional_property_keys
          self.class.optional_property_keys || []
        end
        
        def create_context
          create_context_for_properties(self.required_property_keys, required: true)
          create_context_for_properties(self.optional_property_keys)
        end

        def create_context_for_properties(properties, required: false)
          properties.uniq.each do |property|
            if property.is_a? Hash
              property.each do |key, value|
                method_name = value[:as] || key
                raise "required property '#{key}' is missing for '#{self.class}'" if required && self.options[key].nil?
                context.send(:"#{method_name}=", self.options.delete(key))
              end
            else
              raise "required property '#{property}' is missing for '#{self.class}'" if required && self.options[property].nil?
              context.send(:"#{property}=", self.options.delete(property))
            end
          end if properties
        end
    
      end
    end
  end
end