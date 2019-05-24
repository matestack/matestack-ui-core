module Time::Cell
  class Time < Component::Cell::Static

    def setup
      @tag_attributes.merge!({
        "datetime": options[:datetime] ||= nil
      })
    end

  end
end
