module Matestack::Ui::Core::Toggle
  class Toggle < Matestack::Ui::Core::Component::Dynamic

    vue_js_component_name "matestack-ui-core-toggle"

    def initialize(*args)
      super
      @tag_attributes.merge!({
        "v-if": "showing"
      })
    end

  end
end
