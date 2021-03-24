module Matestack
  module Ui
    module VueJs
      module Components
        class Transition < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-transition'

          optional :path, :delay

          def response
            a attributes do
              if block_given?
                yield
              end
              plain self.text if self.text
            end
          end

          protected

          def attributes
            options.merge({
              href: ctx.path,
              '@click.prevent': "navigateTo(\"#{ctx.path}\")",
              "v-bind:class": "{ active: isActive, 'active-child': isChildActive }"
            })
          end

          def config
            {
              link_path: ctx.path,
              delay: ctx.delay,
            }
          end

        end
      end
    end
  end
end