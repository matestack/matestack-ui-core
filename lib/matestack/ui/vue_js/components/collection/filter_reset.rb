module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class FilterReset < Matestack::Ui::Component

            def response
              link '@click': 'resetFilter()' do
                yield
              end
            end

          end
        end
      end
    end
  end
end
