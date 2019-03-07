module Timefield::Cell
  class Timefield < Component::Cell::Static

    def setup
      @tag_attributes.merge!({ "class": options[:class],
        "id": component_id,
        "datetime": options[:time] ||= nil
      })
    end

  end
end
