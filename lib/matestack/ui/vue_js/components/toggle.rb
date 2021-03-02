module Matestack
  module Ui
    module VueJs
      module Components
        class Toggle < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-toggle'

          def response
            div class: "matestack-toggle-component-root", 'v-if': 'showing' do
              yield
            end
          end

          def config
            {
              show_on: options[:show_on],
              hide_on: options[:hide_on],
              hide_after: options[:hide_after],
              init_show: options[:init_show],
            }
          end

        end
      end
    end
  end
end