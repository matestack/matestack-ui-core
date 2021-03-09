module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Base < Matestack::Ui::VueJs::Vue

            internal :key, :type, :label, :init, :errors, :id, :multiple, :placeholder

            def form_context
              Matestack::Ui::VueJs::Components::Form::Context.form_context
            end

            # options/settings

            def key
              internal_context.key
              # @key ||= options.delete(:key)
            end

            def type
              internal_context.type
              # @type ||= options[:type]
            end

            def input_label
              internal_context.label
              # @input_label ||= options.delete(:label)
            end

            def init
              internal_context.init
              # @init = @init.nil? ? options.delete(:init) : @init
            end

            def error_config
              internal_context.errors
              # @error_config = @error_config.nil? ? self.options.delete(:errors) : @error_config
            end

            def id
              internal_context.id || key
              # @id ||= options.delete(:id) || key
            end

            def multiple
              internal_context.multiple
              # @multiple ||= options.delete(:multiple)
            end

            def placeholder
              internal_context.placeholder
              # @placeholder ||= options.delete(:placeholder)
            end

            # calculated attributes

            def attributes
              {
                ref: "input.#{attribute_key}",
                id: id,
                '@change': change_event,
                'init-value': init_value || (internal_context.multiple ? [] : nil),
                'v-bind:class': "{ '#{input_error_class}': #{error_key} }",
              }.tap do |attrs|
                attrs[:"#{v_model_type}"] = input_key unless type == :file
              end
            end

            def attribute_key
              key.to_s + "#{'[]' if internal_context.multiple && internal_context.type == :file}"
              # attr_key = if for_attribute = form_context.for_attribute
              #   "#{for_attribute}.#{key}"
              # else
              #   key.to_s
              # end
            end

            def name
              attribute_key
            end

            def init_value
              return init unless init.nil?
              if form_context.for_option.respond_to?(key)
                form_context.for_option.send(key)
              end
            end

            def change_event
              input_changed = "inputChanged('#{attribute_key}');"
              input_changed << "filesAdded('#{attribute_key}');" if type == :file
              input_changed
            end

            def input_key
              "$parent.data['#{key}']"
            end

            # set v-model.number for all numeric init values
            def v_model_type
              (type == :number || init_value.is_a?(Numeric)) ? 'v-model.number' : 'v-model'
            end

            # error rendering

            def display_errors?
              if form_context.internal_context.errors == false
                error_config ? true : false
              else
                error_config != false
              end
            end

            def error_key
              "$parent.errors['#{key}']"
            end

            def error_class
              get_from_error_config(:class) || 'error'
            end

            def error_tag
              get_from_error_config(:tag) || :div
              # error_config.is_a?(Hash) && error_config.dig(:tag) || :div
            end

            def input_error_class
              get_from_error_config(:input, :class) || 'error'
              # error_config.is_a?(Hash) && error_config.dig(:input, :class) || 'error'
            end

            def wrapper_tag
              get_from_error_config(:wrapper, :tag) || :div
              # error_config.is_a?(Hash) && error_config.dig(:wrapper, :tag) || :div
            end

            def wrapper_error_class
              get_from_error_config(:wrapper, :class) || 'errors'
              # error_config.is_a?(Hash) && error_config.dig(:wrapper, :class) || 'errors'
            end

            def get_from_error_config(*keys)
              comp_error_config = error_config.dig(*keys) if error_config.is_a?(Hash)
              form_error_config = form_context.internal_context.errors.dig(*keys) if form_context.internal_context.errors.is_a?(Hash)
              comp_error_config || form_error_config
            end

            def render_errors
              if display_errors?
                Matestack::Ui::Component.new(wrapper_tag, class: wrapper_error_class, 'v-if': error_key) do
                  Matestack::Ui::Component.new(error_tag, class: error_class, 'v-for': "error in #{error_key}") do
                    plain vue.error
                  end
                end
              end
            end

          end
        end
      end
    end
  end
end