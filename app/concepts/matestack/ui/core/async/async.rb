module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Rerender

    def initialize(*args)
      super
      @component_config[:component_key] = self.class.to_s
    end

    def setup
      @tag_attributes.merge!({
        "v-if": "showing"
      })
    end

    def authorized?
      true
    end

    def prepare
      # magic business logic
    end


    def response
      # ...
    end

    private
    # TODO: this is not how this is supposed to work....
    def generate_component_name
      @component_name = 'matestack-ui-core-async'
      @component_class = @component_name
    end
  end
end
