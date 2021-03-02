module Matestack
  module Ui
    module VueJs
      module Components
        class Transition < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-transition'

          def response
            div attributes do
              yield
            end
          end

          protected

          def attributes
            {
              href: options[:path],
              '@click.prevent': "navigateTo(\"#{options[:path]}\")",
              "v-bind:class": "{ active: isActive, 'active-child': isChildActive }"
            }
          end

          def config
            {
              link_path: options[:path],
            }
          end

        end
      end
    end
  end
end