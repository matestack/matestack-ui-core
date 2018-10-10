module Component::Cell
  class Static < Component::Cell::Dynamic

    def initialize(model=nil, options={})
      super
      if options[:dynamic]
        @static = false
        @component_class = "anonym-dynamic-component-cell"
      else
        @static = true
      end
    end

    def show(&block)
      if @static
        render(view: :static, &block)
      else
        render(view: :dynamic, &block)
      end
    end

  end
end
