module Form::Cell
  class Form < Component::Cell::Dynamic

    REQUIRED_KEYS = [:for, :path, :method]

    def setup
      begin
        @component_config[:for] = form_wrapper
        @component_config[:submit_path] = submit_path
        @component_config[:method] = options[:method]
        @component_config[:success] = options[:success]
        unless options[:success].nil?
          unless options[:success][:transition].nil?
            @component_config[:success][:transition][:path] = transition_path options[:success]
          end
        end
        @component_config[:failure] = options[:failure]
        unless options[:failure].nil?
          unless options[:failure][:transition].nil?
            @component_config[:failure][:transition][:path] = transition_path options[:failure]
          end
        end
        @tag_attributes.merge!({"@submit.prevent": true})
      rescue => e
        raise "Form component could not be setted up. Reason: #{e}"
      end
    end

    def submit_path
      begin
        if options[:path].is_a?(Symbol)
          return ::Rails.application.routes.url_helpers.send(options[:path], options[:params])
        else
          return options[:path]
        end
      rescue
        raise "Submit path not found"
      end
    end

    def transition_path callback_options
      begin
        if callback_options[:transition][:path].is_a?(Symbol)
          return ::Rails.application.routes.url_helpers.send(
            callback_options[:transition][:path],
            callback_options[:transition][:params]
          )
        else
          return callback_options[:transition][:path]
        end
      rescue
        raise "Transition path not found"
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
