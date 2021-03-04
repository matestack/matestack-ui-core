module Matestack
  module Ui
    module VueJs
      module Components
        class Transition < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-transition'

          internal :path

          def response
            div attributes do
              yield
            end
          end

          protected

          def attributes
            {
              href: internal_context.path,
              '@click.prevent': "navigateTo(\"#{internal_context.path}\")",
              "v-bind:class": "{ active: isActive, 'active-child': isChildActive }"
            }
          end

          def config
            {
              link_path: internal_context.path,
            }
          end

        end
      end
    end
  end
end