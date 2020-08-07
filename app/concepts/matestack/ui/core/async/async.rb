module Matestack::Ui::Core::Async
  class Async < Matestack::Ui::Core::Component::Rerender
    vue_js_component_name "matestack-ui-core-async"
    
    optional :id # will be required in 1.0.0

    def initialize(*args)
      super
      ActiveSupport::Deprecation.warn(
        'Calling async components without id is deprecated. Instead provide a unique id for async components.'
      ) if id.blank?
      @component_config[:component_key] = id || "async_#{Digest::SHA256.hexdigest(caller[3])}"
      @tag_attributes.merge!({
        "v-if": "showing",
        id: @component_config[:component_key]
      })
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
