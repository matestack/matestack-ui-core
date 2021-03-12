module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class FilterSubmit < Matestack::Ui::Component

            def response
              link '@click': 'submitFilter()' do
                yield
              end
            end

          end
        end
      end
    end
  end
end
