module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Order < Matestack::Ui::VueJs::Vue
            vue_name 'matestack-ui-core-collection-order'

            required :id

            def response
              div do
                yield
              end
            end

            def vue_props
              {
                id: ctx.id
              }
            end

          end
        end
      end
    end
  end
end
