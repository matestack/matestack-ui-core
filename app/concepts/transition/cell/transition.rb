module Transition::Cell
  class Transition < Component::Cell::Static

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
