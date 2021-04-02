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
            set_text
            super
          end
        end

        module ClassMethods
          extend Gem::Deprecate

          def required(*args)
            @required = (@required || []).concat(args)
          end
          alias requires required

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

        def set_text
          # the text property is treated specially since 2.0.0 enables text injection for all components like:
          #
          # some_component "foo", class: "whatever" -> self.text -> "foo"
          #
          # prior to 2.0.0, text injection happened like that:
          #
          # some_component text: "foo", class: "whatever" -> self.options[:text] -> "foo"
          #
          # in both cases "foo" should be available via self.context.text AND self.text
          #
          # in 2.0.0 text is available via context.text if text is marked as required or optional
          # in order to have a consistent access, we make this text accessable via self.text as well in this case
          # in all cases, text is accessable via self.text AND self.context.text
          # we make the passed in text option available via context.text by default, even if not marked as required or optional
          #
          # additionally we need to delete text from the options, as they might be used to be rendered as
          # tag attributes without any whitelisting as happened prior to 2.0.0
          self.text = self.options.delete(:text) if self.options.has_key?(:text)
          self.context.text = self.text
        end
        
      end
    end
  end
end
