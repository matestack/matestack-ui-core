module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class OrderToggle < Matestack::Ui::Component

            required :key

            def response
              a '@click': "toggleOrder(\"#{ctx.key}\")" do
                yield
              end
            end

          end
        end
      end
    end
  end
end
