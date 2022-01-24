module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class FilterReset < Matestack::Ui::Component

            def response
              a 'v-on:click': 'vc.resetFilter()' do
                yield
              end
            end

          end
        end
      end
    end
  end
end
