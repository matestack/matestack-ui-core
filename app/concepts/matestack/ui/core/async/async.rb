module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Dynamic

    def setup
      @rerender = true
      @tag_attributes.merge!({
        "v-if": "showing"
      })
    end

  end
end
