module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Radio < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-radio'

            def response
              div class: 'matestack-ui-core-form-radio' do
                radio_options.to_a.each do |item|
                  input radio_attributes(item)
                  label item_label(item), for: item_id(item)
                end
                render_errors
              end
            end

            def component_id
              "radio-component-for-#{key}"
            end

            def config
              {
                init_value: init_value,
              }
            end

            # checkbox rendering


            def radio_attributes(item)
              attributes.merge({
                id: item_id(item),
                name: item_label(item),
                value: item_value(item),
                type: :radio,
                ref: "select.#{key}",
                'value-type': item_value(radio_options.first).is_a?(Integer) ? Integer : nil,
              })
            end

            # checkbox options

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
              "#{key}_#{item_value(item)}"
            end

          end
        end
      end
    end
  end
end