module Matestack::Ui::Core::Cable
  class Cable < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name 'matestack-ui-core-cable'

    requires :id

    def setup
      component_config[:component_key] = id
    end
    
    def show
      render :cable
    end

    def render_content
      render :children_wrapper do
        render :children
      end
    end

    def children_wrapper_attributes
      html_attributes.merge({
        id: component_config[:component_key]
      })
    end

  end
end