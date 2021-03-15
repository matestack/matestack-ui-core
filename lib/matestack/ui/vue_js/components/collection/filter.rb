module Matestack
  module Ui
    module VueJs
      module Components
        module Collection

          class Filter < Matestack::Ui::VueJs::Components::Form::Form
            vue_name 'matestack-ui-core-collection-filter'

            required :id
            required :filter_state

            def config
              super.merge({
                id: ctx.id
              })
            end

            def for_option
              p OpenStruct.new(ctx.filter_state).inspect
              OpenStruct.new(ctx.filter_state)
              # p ctx.filter_state.inspect
              # FilterState.new("foobar")
            end

          end

          FilterState = Struct.new(:title)

        end
      end
    end
  end
end
