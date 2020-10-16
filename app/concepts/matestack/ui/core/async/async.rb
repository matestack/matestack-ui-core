module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name "matestack-ui-core-async"

    requires :id # required since 1.1.0

    def initialize(*args)
      super
      component_config[:component_key] = id
      if included_config.present? && included_config[:isolated_parent_class].present?
        component_config[:parent_class] = included_config[:isolated_parent_class]
      end
    end

    def children_wrapper_attributes
      html_attributes.merge({
        "v-if": "showing",
        id: component_config[:component_key]
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
      component_config[:component_key]
    end

  end
end
