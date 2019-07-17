module Matestack::Ui::Core::Link
  class Link < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        "class": options[:class],
        "id": component_id,
        "method": options[:method],
        "target": options[:target] ||= nil,
        "href": link_path
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
