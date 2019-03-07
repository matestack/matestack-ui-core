module Time::Cell
  class Time < Component::Cell::Static

    def setup
      @tag_attributes.merge!({ "class": options[:class],
        "id": component_id,
        "datetime": options[:datetime] ||= nil
      })
    end

  end
end
