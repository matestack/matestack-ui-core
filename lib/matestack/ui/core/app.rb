module Matestack
  module Ui
    module Core
      class App < Base
        
        def initialize(options = {})
          @controller = Context.controller
          Context.app = self
          super(nil, nil, options)
        end

        def component_attributes
          {
            is: 'matestack-ui-core-app',
            'inline-template': true,
          }
        end

        def loading_state_element
        end


        # layout class method to specify if a rails layout should be used
        def self.inherited(subclass)
          subclass.layout(@layout)
          super
        end
          
        def self.layout(layout = nil)
          @layout = layout ? layout : @layout
        end
        
      end
    end
  end
end