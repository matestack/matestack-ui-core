module Matestack::Ui::Core::Component
  class Dynamic < Base

    def initialize(model = nil, options = {})
      super
      @static = false
    end
  end
end
