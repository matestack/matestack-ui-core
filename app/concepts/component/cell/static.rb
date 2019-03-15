module Component::Cell
  class Static < Component::Cell::Dynamic

    def initialize(model=nil, options={})
      super
      if options[:dynamic]
        @static = false
        @rerender = true
        @component_class = "anonym-dynamic-component-cell"
      else
        @static = true
      end
    end

  end
end
