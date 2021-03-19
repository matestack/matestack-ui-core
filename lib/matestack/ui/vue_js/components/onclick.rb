module Matestack
  module Ui
    module VueJs
      module Components
        class Onclick < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-onclick'

          optional :emit, :data

          def response
            div onclick_attributes do
              yield
            end
          end

          def onclick_attributes
            options.merge({
              class: "matestack-onclick-component-root", 
              '@click': 'perform'
            })
          end

          protected

          def config
            {
              emit: ctx.emit,
              data: ctx.data,
            }
          end

        end
      end
    end
  end
end