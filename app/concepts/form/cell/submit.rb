module Form::Cell
  class Submit < Component::Cell::Static

    def setup
      @tag_attributes.merge!({ "@click.prevent": "perform" })
    end

  end
end
