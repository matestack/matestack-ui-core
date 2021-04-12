module Matestack
  module Ui
    module Core
      class VueAttributes

        def self.method_missing(message, *args, &block)
          return "{{ #{message} }}"
        end
        
      end
    end
  end
end