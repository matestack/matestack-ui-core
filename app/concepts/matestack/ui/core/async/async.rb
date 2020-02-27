module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Rerender

    def initialize(*args)
      super
      @component_config[:component_key] = self.class.to_s
    end

    def authorized?
      true
    end

    def response
      raise "implement me"
    end

    private
    # TODO: this is not how this is supposed to work....
    def generate_component_name
      @component_name = 'matestack-ui-core-async'
      @component_class = @component_name
    end
  end
end
