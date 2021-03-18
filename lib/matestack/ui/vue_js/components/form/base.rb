module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Base < Matestack::Ui::VueJs::Vue

            optional :key, :type, :label, :init, :errors, :id, :multiple, :placeholder

            def form_context
              Matestack::Ui::VueJs::Components::Form::Context.form_context
            end

            # options/settings

            def key
              ctx.key
            end

            def type
              ctx.type
            end

            def input_label
              ctx.label
            end

            def init
              ctx.init
            end

            def error_config
              ctx.errors
            end

            def id
              ctx.id || key
            end

            def multiple
              ctx.multiple
            end

            def placeholder
              ctx.placeholder
            end

            # calculated attributes

            def attributes
              (options || {}).merge({
                ref: "input.#{attribute_key}",
                id: id,
                type: ctx.type,
                multiple: ctx.multiple,
                placeholder: ctx.placeholder,
                '@change': change_event,
                'init-value': init_value || (ctx.multiple ? [] : nil),
                'v-bind:class': "{ '#{input_error_class}': #{error_key} }",
              }).tap do |attrs|
                attrs[:"#{v_model_type}"] = input_key unless type == :file
              end
            end

            def attribute_key
              key.to_s + "#{'[]' if ctx.multiple && ctx.type == :file}"
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
              if form_context.ctx.errors == false
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
              form_error_config = form_context.ctx.errors.dig(*keys) if form_context.ctx.errors.is_a?(Hash)
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