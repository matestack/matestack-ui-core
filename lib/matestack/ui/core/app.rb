module Matestack
  module Ui
    module Core
      class App < Base
        
        def initialize(options = {})
          @controller = Context.controller
          super(nil, nil, options)
        end

        # def create_children
        #   self.app do
        #     self.response
        #   end
        # end

        def app
          Base.new(:component, component_attributes) do
            div class: 'matestack-app-wrapper' do
              yield
            end
          end
        end

        def component_attributes
          {
            is: 'matestack-ui-core-app',
            'inline-template': true,
          }
        end
        
      end
    end
  end
end