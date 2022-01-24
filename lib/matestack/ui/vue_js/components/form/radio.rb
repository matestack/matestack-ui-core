module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Radio < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-radio'

            def response
              div class: 'matestack-ui-core-form-radio' do
                render_options
                render_errors
              end
            end

            def render_options
              radio_options.to_a.each do |item|
                input radio_attributes(item)
                label item_label(item), ":for": item_id(item)
              end
            end

            def component_id
              "radio-component-for-#{key}"
            end

            def vue_props
              {
                init_value: init_value,
                key: key,
              }
            end

            def radio_attributes(item)
              attributes.merge({
                ":id": item_id(item),
                name: item_name(item),
                type: :radio,
                "matestack-ui-core-ref": scoped_ref("select.#{key}"),
                'value-type': value_type(item_value(radio_options.first))
              }).tap do |attrs|
                attrs[value_key(item)] = item_value(item)
              end
            end

            def radio_options
              @radio_options ||= options.delete(:options)
            end

            # calculated attributes

            def item_value(item)
              item.is_a?(Array) ? item.last : item
            end

            def item_label(item)
              item.is_a?(Array) ? item.first : item
            end

            def item_id(item)
              "#{id || key}+'_#{item_value(item)}'"
            end

            def item_name(item)
              "#{key}_#{item_value(item)}"
            end

            def v_model_type
              item_value(radio_options.first).is_a?(Numeric) ? 'v-model.number' : 'v-model'
            end

            def value_key(value)
              if value.is_a?(Array)
                value[1].is_a?(Numeric) ? ':value' : 'value'
              else
                value.is_a?(Numeric) ? ':value' : 'value'
              end
            end

          end
        end
      end
    end
  end
end
