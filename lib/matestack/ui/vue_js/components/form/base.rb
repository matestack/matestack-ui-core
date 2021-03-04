module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Base < Matestack::Ui::VueJs::Vue

            def form_context
              Matestack::Ui::VueJs::Components::Form::Context.form_context
            end

            # options/settings

            def key
              @key ||= options.delete(:key)
            end

            def type
              @type ||= options[:type]
            end

            def input_label
              @input_label ||= options.delete(:label)
            end

            def init
              @init ||= options.delete(:init)
            end

            def error_config
              @error_config ||= options.delete(:errors) || {}
            end

            def id
              @id ||= options.delete(:id) || attribute_key
            end

            def multiple
              @multiple ||= options.delete(:multiple)
            end

            def placeholder
              @placeholder ||= options.delete(:placeholder)
            end

            # calculated attributes

            def attributes
              {
                ref: "input.#{key}",
                id: id,
                '@change': change_event,
                'init-value': init_value,
                'v-bind:class': "{ '#{error_class}': #{error_key} }",
              }.tap do |attrs|
                attrs[:"#{v_model_type}"] = (type == :file ? {} : input_key)
              end
            end

            def attribute_key
              attr_key = if for_attribute = form_context.for_attribute
                "#{for_attribute}.#{key}"
              else
                key.to_s
              end
            end

            def name
              attribute_key
            end

            def init_value
              return init unless init
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

            def error_key
              "$parent.errors['#{key}']"
            end

            def error_class
              error_config.dig(:class) || 'error'
            end

            # TODO add options to customize every tag and error class
            def render_errors
              div class: 'errors', 'v-if': error_key do
                div class: 'error', 'v-for': "error in #{error_key}" do
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