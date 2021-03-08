module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Filter < Matestack::Ui::VueJs::Vue 
            vue_name 'matestack-ui-core-collection-filter'
            
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