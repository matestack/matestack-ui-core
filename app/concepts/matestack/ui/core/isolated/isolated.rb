module Matestack::Ui::Core::Isolated
  class Isolated < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name "matestack-ui-core-isolate"

    def initialize(*args)
      super
      @public_options = args.map { |hash| hash[:public_options] }[0]
    end

    def public_options
      @public_options ||= {}
    end

    # def params
    #   context[:params] || matestack_context[:params]
    # end

    def setup
      @component_config[:component_class] = self.class.name
      @component_config[:public_options] = @options[:public_options]
      @component_config[:defer] = @options[:defer]
      @component_config[:rerender_on] = @options[:rerender_on]
      @component_config[:rerender_delay] = @options[:rerender_delay]
      @component_config[:init_on] = @options[:init_on]
    end

    def loading_classes
      { "v-bind:class": "{ 'loading': loading === true }" }
    end

    # overwrite parent class render mechanism in order to make sure to only render wrapper
    def render_content
      show
    end

    # only render vuejs component wrapper on show
    def show
      render :isolated
    end

    # this method gets called when the isolate vuejs component requests isolated content
    def render_isolated_content
      if authorized?
        render :children_wrapper do
          render :children
        end
      end
    end

    def authorized?
      raise "please implement the `authorized? method: isolated components have to be authorized separately"
    end

    def loading_state_element
      nil # overwrite in subclass
    end

  end
end
