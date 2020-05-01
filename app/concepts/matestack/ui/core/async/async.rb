module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Rerender

    def vuejs_component_name
      "matestack-ui-core-async"
    end

    def initialize(*args)
      super
      @tag_attributes.merge!({
        "v-if": "showing"
      })
      @component_config[:component_key] = Digest::SHA256.hexdigest(caller[3])
    end

    def get_component_key
      @component_config[:component_key]
    end

    def authorized?
      true
    end

    # def response
    #   raise "implement me"
    # end

    private
    # TODO: this is not how this is supposed to work....
    def generate_component_name
      @component_name = 'matestack-ui-core-async'
      @component_class = @component_name
    end
  end
end
