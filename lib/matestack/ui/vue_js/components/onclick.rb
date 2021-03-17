module Matestack
  module Ui
    module VueJs
      module Components
        class Onclick < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-onclick'

          optional :emit, :data

          def response
            div class: "matestack-onclick-component-root", '@click': 'perform' do
              yield
            end
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