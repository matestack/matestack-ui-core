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
              'v-on:click.prevent': "vc.navigateTo(\"#{ctx.path}\")",
              "v-bind:class": "{ active: vc.isActive, 'active-child': vc.isChildActive }"
            })
          end

          def vue_props
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
