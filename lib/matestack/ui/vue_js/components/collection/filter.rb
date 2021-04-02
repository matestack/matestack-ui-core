module Matestack
  module Ui
    module VueJs
      module Components
        module Collection

          class Filter < Matestack::Ui::VueJs::Components::Form::Form
            vue_name 'matestack-ui-core-collection-filter'

            required :id
            required :filter_state

            def vue_props
              super.merge({
                id: ctx.id
              })
            end

            def for_option
              OpenStruct.new(ctx.filter_state)
            end

          end
          
        end
      end
    end
  end
end
