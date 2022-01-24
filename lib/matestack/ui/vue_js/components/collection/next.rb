module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Next < Matestack::Ui::Component

            def response
              a options.merge('v-on:click': 'vc.next()') do
                yield
              end
            end

          end
        end
      end
    end
  end
end
