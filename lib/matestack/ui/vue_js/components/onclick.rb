module Matestack
  module Ui
    module VueJs
      module Components
        class Onclick < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-onclick'

          optional :emit, :data

          def response
            a onclick_attributes do
              yield
            end
          end

          def onclick_attributes
            options.merge({
              class: "matestack-onclick-component-root",
              '@click.prevent': 'perform',
              href: "#"
            })
          end

          protected

          def vue_props
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
