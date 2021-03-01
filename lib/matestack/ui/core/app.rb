module Matestack
  module Ui
    module Core
      class App < Base
        
        def initialize(options = {})
          @controller = Context.controller
          super(nil, nil, options)
        end
        
      end
    end
  end
end