module Form::Cell
  class Form < Component::Cell::Dynamic

    def setup
      @component_config[:for] = form_wrapper
      @component_config[:submit_path] = submit_path
      @component_config[:method] = options[:method]
      @component_config[:success] = options[:success]
      unless options[:success][:transition].nil?
        @component_config[:success][:transition][:path] = transition_path
      end
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

    def transition_path
      begin
        return ::Rails.application.routes.url_helpers.send(
          options[:success][:transition][:path],
          options[:success][:transition][:params]
        )
      rescue
        "path_not_found"
      end
    end

    def form_wrapper
      case options[:for]
      when Symbol
        return options[:for]
      when String
        return options[:for]
      end

      if options[:for].respond_to?(:model_name)
        return options[:for].model_name.singular
      end
    end


  end
end
