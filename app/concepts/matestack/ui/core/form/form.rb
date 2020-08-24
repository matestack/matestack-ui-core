module Matestack::Ui::Core::Form
  class Form < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name "matestack-ui-core-form"
    
    html_attributes :'accept-charset', :action, :autocomplete, :enctype, :method, :name, :novalidate, :rel, :target

    requires :path, for: { as: :for_option }, method: { as: :form_method }
    optional :success, :failure, :multipart, params: { as: :form_params }

    def setup
      begin
        @component_config[:for] = form_wrapper
        @component_config[:submit_path] = submit_path
        @component_config[:method] = form_method
        @component_config[:success] = success
        @component_config[:multipart] = multipart == true
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
      rescue => e
        raise "Form component could not be setted up. Reason: #{e}"
      end
    end

    def form_attributes
      html_attributes.merge({
        "@submit.prevent": true,
        "class": "matestack-form #{options[:class]}",
        "v-bind:class": "{ 'has-errors': hasErrors(), 'loading': loading }"
      })
    end

    def submit_path
      begin
        if path.is_a?(Symbol)
          return ::Rails.application.routes.url_helpers.send(path, form_params)
        else
          return path
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

    def form_wrapper
      case for_option
      when Symbol
        return for_option
      when String
        return for_option
      end

      if for_option.respond_to?(:model_name)
        return for_option.model_name.singular
      end
    end


  end
end
