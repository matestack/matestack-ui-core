module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Previous < Matestack::Ui::Component
            
            def response
              link '@click': 'previous()' do
                yield
              end
            end
            
          end
        end
      end
    end
  end
end