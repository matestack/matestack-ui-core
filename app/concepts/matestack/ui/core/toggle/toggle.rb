module Matestack::Ui::Core::Toggle
  class Toggle < Matestack::Ui::Core::Component::Dynamic

    def vuejs_component_name
      "matestack-ui-core-toggle"
    end

    def initialize(*args)
      super
      @tag_attributes.merge!({
        "v-if": "showing"
      })
    end

  end
end
