module Action::Cell
  class Action < Component::Cell::Dynamic

    def setup
      @component_config[:action_path] = action_path
      @component_config[:method] = options[:method]
      @component_config[:success] = options[:success]
    end

    def action_path
      begin
        return ::Rails.application.routes.url_helpers.send(options[:path], options[:params])
      rescue
        "path_not_found"
      end
    end

  end
end
