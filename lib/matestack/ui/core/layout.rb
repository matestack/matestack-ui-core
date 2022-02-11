module Matestack
  module Ui
    module Core
      class Layout < Base

        def initialize(options = {})
          @controller = Context.controller
          Context.layout = self
          super(nil, nil, options)
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
