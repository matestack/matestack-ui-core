module Col::Cell
  class Col < Component::Cell::Component

    def setup
      @static = true
    end

    def col_classes
      classes = []

      classes << "col"
      classes = Customize::Ui::Core::Col.new.col_classes(classes, options)

      return classes.join(" ")
    end

  end
end
