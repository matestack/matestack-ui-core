module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Content < Matestack::Ui::VueJs::Vue
            vue_name 'matestack-ui-core-collection-content'
            
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