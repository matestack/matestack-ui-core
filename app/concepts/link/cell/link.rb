module Link::Cell
  class Link < Component::Cell::Static

    def setup
      @tag_attributes.merge!({ "class": options[:class],
        "id": component_id,
        "method": options[:method] ||= :get,
        "target": options[:target] ||= nil
      })
    end

    def link_path
      if options[:path].is_a?(Symbol)
        return ::Rails.application.routes.url_helpers.send(options[:path], options[:params])
      end
      if options[:path].is_a?(String)
        return options[:path]
      end
    end

  end
end
