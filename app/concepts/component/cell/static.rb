module Component::Cell
  class Static < Component::Cell::Dynamic

    def initialize(model=nil, options={})
      super
      @static = true
    end

    def show(&block)
      render(view: :static, &block)
    end

  end
end
