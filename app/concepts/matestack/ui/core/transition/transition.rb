module Matestack::Ui::Core::Transition
  class Transition < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name "matestack-ui-core-transition"

    requires :path
    optional :text, params: { as: :transition_params }

    def setup
      @component_config[:link_path] = link_path
    end

    def transition_attributes
      html_attributes.merge(
        "href": link_path,
        "@click.prevent": navigate_to(link_path),
        "v-bind:class": "{ active: isActive, 'active-child': isChildActive }"
      )
    end

    def link_path
      if path.is_a?(Symbol)
        return resolve_path
      end
      if path.is_a?(String)
        return path
      end
    end

    def resolve_path
      begin
        return ::Rails.application.routes.url_helpers.send(path, transition_params)
      rescue => e
        raise "path '#{path}' not found, using params: #{transition_params}"
      end
    end

  end
end
