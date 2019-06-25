module Matestack::Ui::Core::Action
  class Action < Matestack::Ui::Core::Component::Dynamic

    def setup
      @component_config[:action_path] = action_path
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
      if options[:notify].nil?
        @component_config[:notify] = true
      end
    end

    def action_path
      begin
        if options[:path].is_a?(Symbol)
          return ::Rails.application.routes.url_helpers.send(options[:path], options[:params])
        else
          return options[:path]
        end
      rescue
        raise "Action path not found"
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

  end
end
