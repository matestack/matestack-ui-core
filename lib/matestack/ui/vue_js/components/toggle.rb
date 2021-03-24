module Matestack
  module Ui
    module VueJs
      module Components
        class Toggle < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-toggle'

          optional :show_on, :hide_on, :hide_after, :init_show

          def response
            div toggle_attributes do
              yield
            end
          end

          def toggle_attributes
            options.merge({
              class: "matestack-toggle-component-root", 
              'v-if': 'showing'
            })
          end

          protected

          def config
            {
              show_on: ctx.show_on,
              hide_on: ctx.hide_on,
              hide_after: ctx.hide_after,
              init_show: ctx.init_show,
            }
          end

        end
      end
    end
  end
end