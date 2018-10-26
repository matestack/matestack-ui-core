module Form::Cell
  class Form < Component::Cell::Dynamic

    def setup
      @component_config[:submit_path] = submit_path
      @component_config[:method] = options[:method]
      @component_config[:success] = options[:success]
      if options[:notify].nil?
        @component_config[:notify] = true
      end

      @tag_attributes.merge!({"@submit.prevent": true})
    end

    def submit_path
      begin
        return ::Rails.application.routes.url_helpers.send(options[:path], options[:params])
      rescue
        "path_not_found"
      end
    end


  end
end
