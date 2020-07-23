module Matestack::Ui::Core::Action
  class Action < Matestack::Ui::Core::Component::Dynamic
    optional :path, :success, :failure, :notify, :confirm, 
      method: { as: :action_method }, params: { as: :action_params }

    def vuejs_component_name
      'matestack-ui-core-action'
    end

    def setup
      @component_config[:action_path] = action_path
      @component_config[:method] = action_method
      @component_config[:success] = success
      unless success.nil?
        unless success[:transition].nil?
          @component_config[:success][:transition][:path] = transition_path success
        end
        unless success[:redirect].nil?
          @component_config[:success][:redirect][:path] = redirect_path success
        end
      end
      @component_config[:failure] = failure
      unless failure.nil?
        unless failure[:transition].nil?
          @component_config[:failure][:transition][:path] = transition_path failure
        end
        unless failure[:redirect].nil?
          @component_config[:failure][:redirect][:path] = redirect_path failure
        end
      end
      if notify.nil?
        @component_config[:notify] = true
      end
      if @component_config[:confirm] = confirm
        @component_config[:confirm_text] = confirm.try(:[], :text) || "Are you sure?"
      end
    end

    def action_path
      begin
        if path.is_a?(Symbol)
          return ::Rails.application.routes.url_helpers.send(path, action_params)
        else
          return path
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

    def redirect_path callback_options
      begin
        if callback_options[:redirect][:path].is_a?(Symbol)
          return ::Rails.application.routes.url_helpers.send(
            callback_options[:redirect][:path],
            callback_options[:redirect][:params]
          )
        else
          return callback_options[:redirect][:path]
        end
      rescue
        raise "Redirect path not found"
      end
    end

  end
end
