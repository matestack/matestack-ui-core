module Matestack::Ui::Core::Isolate
  class Isolate < Matestack::Ui::Core::Component::Static

    def setup
      @cached_params = @options[:cached_params]
      @component_key = @component_key + "__" + @argument.to_s
      @component_key = @component_key + "(" + @cached_params.to_json + ")" if @cached_params.present?
      @component_config[:component_key] = @component_key
    end

  end
end
