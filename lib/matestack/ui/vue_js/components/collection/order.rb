module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Order < Matestack::Ui::VueJs::Vue 
            vue_name 'matestack-ui-core-collection-order'
            
            def response
              div do
                yield
              end
            end
            
          end
        end
      end
    end
  end
end