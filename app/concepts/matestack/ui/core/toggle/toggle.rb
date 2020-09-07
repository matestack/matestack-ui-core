module Matestack::Ui::Core::Toggle
  class Toggle < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name "matestack-ui-core-toggle"

    def toggle_attributes
      html_attributes.merge({
        "v-if": "showing",
        class: "matestack-toggle-component-root #{options[:class]}".strip
      })
    end

  end
end
