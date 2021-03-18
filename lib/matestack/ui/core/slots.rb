module Matestack
  module Ui
    module Core
      module Slots

        attr_accessor :slots

        def slot(key, *args)
          slots[key].call(*args)
        end

      end
    end
  end
end