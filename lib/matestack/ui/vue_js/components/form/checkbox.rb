module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Checkbox < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-checkbox'

            def response
              div class: 'matestack-ui-core-form-checkbox' do
                render_options
                render_errors
              end
            end

            def render_options
              if checkbox_options
                render_checkbox_options
              else
                render_true_false_checkbox
              end
            end

            def component_id
              "checkbox-component-for-#{key}"
            end

            def vue_props
              {
                init_value: init_value,
                key: key,
              }
            end

            # checkbox rendering

            def render_checkbox_options
              checkbox_options.to_a.each do |item|
                input checkbox_attributes(item)
                label item_label(item), ":for": item_id(item)
              end
            end

            def checkbox_attributes(item)
              {
                ":id": item_id(item),
                type: :checkbox,
                name: item_label(item),
                "#{value_key(item)}": item_value(item),
                "matestack-ui-core-ref": scoped_ref("select.multiple.#{key}"),
                'v-on:change': change_event,
                'init-value': (init_value || []).to_json,
                'v-bind:class': "{ '#{error_class}': #{error_key} }",
                'value-type': value_type(item),
                "#{v_model_type(item)}": input_key,
              }.merge(self.options)
            end

            def render_true_false_checkbox
              input true_false_checkbox_attributes.merge(type: :hidden, ":id": nil)
              input true_false_checkbox_attributes.merge(type: :checkbox, ":id": item_id(1))
              label input_label, ":for": item_id(1) if input_label
            end

            def true_false_checkbox_attributes
              attributes.merge({
                'init-value': init_value_for_single_input,
              })
            end

            def init_value_for_single_input
              if init_value == true || init_value == 1
                return "true"
              end
              if init_value == false || init_value == 0
                return "false"
              end
            end

            # checkbox options

            def checkbox_options
              @checkbox_options ||= options.delete(:options)
            end

            # calculated attributes

            def item_value(item)
              item.is_a?(Array) ? item.last : item
            end

            def item_label(item)
              item.is_a?(Array) ? item.first : item
            end

            def item_id(item)
              "#{id}+'_#{item_value(item).to_s.gsub(" ", '_')}'"
            end

            def value_key(value)
              value.is_a?(Numeric) ? ':value' : 'value'
            end

          end
        end
      end
    end
  end
end
