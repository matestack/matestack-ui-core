module Progress::Cell
  class Progress < Component::Cell::Static

    REQUIRED_KEYS = [:max]

    def setup
      @tag_attributes.merge!({
         'value': options[:value] ||= 0, 
         'max': options[:max]
      })
    end

  end
end
