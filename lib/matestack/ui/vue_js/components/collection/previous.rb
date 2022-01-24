module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Previous < Matestack::Ui::Component

            def response
              a options.merge('v-on:click': 'vc.previous()') do
                yield
              end
            end

          end
        end
      end
    end
  end
end
