module Matestack
  module Ui
    module Core
      module Slots

        attr_accessor :slots

        def slot(some_arg, *args)
          some_arg.call(*args)
        end

      end
    end
  end
end