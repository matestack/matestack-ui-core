module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Rerender
    vue_js_component_name "matestack-ui-core-async"

    optional :id # will be required in 1.0.0

    def initialize(*args)
      super
      ActiveSupport::Deprecation.warn(
        'Calling async components without id is deprecated. Instead provide a unique id for async components.'
      ) if id.blank?
      @component_config[:component_key] = id || "async_#{Digest::SHA256.hexdigest(caller[3])}"
      if @included_config.present? && @included_config[:isolated_parent_class].present?
        @component_config[:parent_class] = @included_config[:isolated_parent_class]
      end
      @tag_attributes.merge!({
        "v-if": "showing",
        id: @component_config[:component_key]
      })
    end

    def show
      render :async
    end

    def render_content
      render :children_wrapper do
        render :children
      end
    end

    def get_component_key
      @component_config[:component_key]
    end

  end
end
