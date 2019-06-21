module Matestack::Ui::Core::Component
  class Static < Matestack::Ui::Core::Component::Dynamic

    def initialize(model=nil, options={})
      super
      if options[:dynamic]
        @static = false
        @rerender = true
        @component_class = "anonym-dynamic-component"
      else
        @static = true
      end
    end

  end
end
