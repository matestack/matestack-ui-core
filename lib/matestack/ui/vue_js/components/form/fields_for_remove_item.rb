module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class FieldsForRemoveItem < Matestack::Ui::Component

            def response
              a class: 'matestack-ui-core-form-fields-for-remove-item', "@click.prevent": "removeItem()" do
                yield if block_given?
              end
            end

          end
        end
      end
    end
  end
end
