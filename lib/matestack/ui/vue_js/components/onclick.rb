module Matestack
  module Ui
    module VueJs
      module Components
        class Onclick < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-onclick'

          def response
            div class: "matestack-onclick-component-root", '@click': 'perform' do
              yield
            end
          end

          protected

          def config
            {
              emit: options[:emit],
              data: options[:data],
            }
          end

        end
      end
    end
  end
end