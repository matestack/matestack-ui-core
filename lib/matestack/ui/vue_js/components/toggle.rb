module Matestack
  module Ui
    module VueJs
      module Components
        class Toggle < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-toggle'

          internal :show_on, :hide_on, :hide_after, :init_show

          def response
            div class: "matestack-toggle-component-root", 'v-if': 'showing' do
              yield
            end
          end

          protected

          def config
            {
              show_on: internal_context.show_on,
              hide_on: internal_context.hide_on,
              hide_after: internal_context.hide_after,
              init_show: internal_context.init_show,
            }
          end

        end
      end
    end
  end
end