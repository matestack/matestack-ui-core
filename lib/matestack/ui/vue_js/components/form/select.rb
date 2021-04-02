module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Select < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-select'

            def response
              div class: 'matestack-ui-core-form-select' do
                label input_label, for: id if input_label
                select select_attributes do
                  render_options
                end
                render_errors
              end
            end

            def render_options
              if placeholder
                option value: nil, disabled: true, selected: init_value.nil?, text: placeholder
              end
              select_options.to_a.each do |item|
                option item_label(item), value: item_value(item), disabled: item_disabled?(item)
              end
            end

            def component_id
              "select-component-for-#{key}"
            end

            def vue_props
              {
                init_value: init_value,
                key: key,
              }
            end

            def select_attributes
              attributes.merge({
                multiple: multiple,
                id: id,
                ref: "select#{'.multiple' if multiple}.#{key}",
                'value-type': value_type(select_options.first),
                'init-value': init_value,
              })
            end

            # select options

            def select_options
              @select_options ||= options.delete(:options)
            end

            # calculated attributes

            def item_value(item)
              item.is_a?(Array) ? item.last : item
            end
            
            def item_label(item)
              item.is_a?(Array) ? item.first : item
            end

            def item_id(item)
              "#{key}_#{item_value(item)}"
            end

            def item_disabled?(item)
              disabled_options && disabled_options.to_a.include?(item)
            end

            def v_model_type
              item_value(select_options.first).is_a?(Numeric) ? 'v-model.number' : 'v-model'
            end

            # attributes

            def disabled_options
              @disabled_options ||= options.delete(:disabled_options)
            end

          end
        end
      end
    end
  end
end