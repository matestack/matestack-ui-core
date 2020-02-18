module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Rerender

    def setup
      @tag_attributes.merge!({
        "v-if": "showing"
      })
    end

  end
end
