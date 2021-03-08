module Matestack
  module Ui
    module VueJs
      module Components
        class Transition < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-transition'

          internal :path, :delay

          def response
            link attributes do
              if block_given?
                yield
              end
              plain self.text if self.text
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
              delay: internal_context.delay,
            }
          end

        end
      end
    end
  end
end