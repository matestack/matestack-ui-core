module Matestack::Ui::Core::Component
  class Base < Trailblazer::Cell
    include Matestack::Ui::Core::Cell
    include Matestack::Ui::Core::HasViewContext

    # probably eed to remove for other tests to be green again
    include Matestack::Ui::Core::DSL

    view_paths << "#{Matestack::Ui::Core::Engine.root}/app/concepts"
    view_paths << "#{::Rails.root}/app/matestack"

    extend ViewName::Flat

    attr_reader :children, :yield_components_to

    # TODO: Seems the `context` method is defined in Cells, would be
    # easy to move up - question really is how much of cells we're still using?
    def initialize(model = nil, options = {})
      # @model also exists with the same content? Is there any reason we wouldn't
      # wanna use it instead of @argument? There's even a `model` accessor for it
      # TODO
      @argument = model
      @options = options

      # TODO works around a semantic where if just a hash is passed apparently
      # those are the options
      @options = model.dup if @options.empty? && model.is_a?(Hash)

      super(model, @options)
      # DSL-relevant
      @children = []
      @current_parent_context = self
      # remember where we need to insert components on yield_components_for usage
      @yield_components_to = nil

      # TODO: everything beyond this point is probably not needed for the
      # Page subclass

      # TODO: potentially only used in form like components
      # Suggestion: Introduce a new super class to remove this complexity
      # from the base class.
      @included_config = @options[:included_config]
      # TODO: only relevant to isolate
      @cached_params = @options[:cached_params]

      # TODO seemingly never accessed? (at least by us)
      # but probably good to expose to have access to current_user & friends
      # #context is defined in `Cell::ViewModel`
      # and it just grabs @options[:context]
      @controller_context = context&.fetch(:controller_context, nil)

      # Options for seemingly advanced functionality
      # This is the configuration for the VueJS component
      @component_config = @options.except(:context, :children, :url_params, :included_config)

      # TODO: no idea why this is called `url_params` it contains
      # much more than this e.g. almost all params so maybe rename it?
      @url_params = context&.[](:params)&.except(:action, :controller, :component_key)
      @component_key = @options[:component_key]

      # TODO: do we realy have to call this every time on initialize or should
      # it maybe be called more dynamically like its dynamic_tag_attributes
      # equivalent in Dynamic?
      set_tag_attributes
      setup
      validate_options
    end

    # TODO: modifies/recreates view lookup paths on every invocation?!
    # At least memoize it I guess...
    # better even maybe/probably give a component an (automatic) way to know
    # exactly where its template is probably based on its own file location.
    # Then no lookup/search has to happen.
    def self.prefixes
      _prefixes = super
      modified_prefixes = _prefixes.map do |prefix|
        prefix_parts = prefix.split("/")

        if prefix_parts.last.include?(self.name.split("::")[-1].downcase)
          prefix_parts[0..-2].join("/")
        else
          prefix
        end

      end

      return modified_prefixes + _prefixes
    end

    def self.views_dir
      return ""
    end

    # Special validation logic
    def validate_options
      if defined? self.class::REQUIRED_KEYS
        self.class::REQUIRED_KEYS.each do |key|
          raise "required key '#{key}' is missing" if options[key].nil?
        end
      end
      custom_options_validation
    end

    def custom_options_validation
      true
    end

    # custom component setup that doesn't seem to be documented
    # but lots of components use it
    def setup
      true
    end

    # Setup meant to be overridden to setup data from DB or what not
    # why not just call these functions at the beginning of whatever
    # we'll call the method like:
    #
    # def respone
    #   result = i_call_stuff
    #   plain result
    # end
    #
    # Seems like it might be more complicated? Not sure probably missing something.
    def prepare
      true
    end

    ## ------------------ Rendering ----------------
    # Invoked by Cell::ViewModel from Rendering#call
    #
    def show
      raise "subclass responsibility"
    end

    def to_html
      show
    end

    def render_content
      # When/if we implement response then our display purely relies on that
      # of our children
      # TODO: this might be another sub class or module for the difference
      # of I have my own template to render vs. I don't
      if respond_to? :response
        render :children
      else
        # We got a template render it around our children
        render do
          render :children
        end
      end
    end

    def component_id
      options[:id] ||= nil
    end

    def js_action name, arguments
      argumentString = arguments.join('", "')
      argumentString = '"' + argumentString + '"'
      [name, '(', argumentString, ')'].join("")
    end

    def navigate_to path
      js_action("navigateTo", [path])
    end

    def get_children
      return options[:children]
    end

    ## ---------------------- DSL ------------------------------
    def add_child(child_class, *args, &block)
      # can't do a splat first followed by a default argument in Ruby,
      # as semantics are unclear. Could put the block as a second argument but
      # that'd make the DSL weird if used this way:
      # add_child Class, proc { ... }, text: "lol"
      #  vs
      # add_child Class, {text: "lol"}, proc { ... }
      # block = args.pop if args.last.is_a?(Proc) || args.last.nil?

      # TODO: there must be a nicer/better/more uniform way to pass this
      # on at some level
      new_args =
        if context
          case args.size
          when 0 then [{context: context}]
          when 1 then
            arg = args.first
            if arg.is_a?(Hash)
              arg[:context] = context
              [arg]
            else
              [arg, {context: context}]
            end
          when 2 then
            args[1][:context] = context
            [args.first, args[1]]
          else
            raise "too many child arguments what are you doing?"
          end
        else
          args
        end


      # TODO nicer interface
      child = child_class.new(*new_args)
      @current_parent_context.children << child

      child.prepare

      child.response if child.respond_to?(:response)

      if block
        previous_parent_context = @current_parent_context
        begin
          @current_parent_context = child.yield_components_to || child
          instance_eval(&block)
        ensure
          @current_parent_context = previous_parent_context
        end
      end

      child
    end

    # compatibility layer to old-school (not needed anymore)
    def components(&block)
      instance_eval &block
    end

    # TODO: partial is weird, I highly recommend removing it
    # it exists in basically 2 forms, one that is basically `send`
    # the other just executes the block it's given.
    # Same thing can now be achieved through simple method calls
    def partial(*args)
      if block_given?
        yield
      else
        send(*args)
      end
    end

    # Another dual purpose method like partial above, just more complex
    def slot(slot_content = [], &block)
      if block_given?
        execution_parent_proxy = Base.new()
        previous_parent_context = @current_parent_context
        @current_parent_context = execution_parent_proxy

        begin
          instance_eval(&block)
        ensure
          @current_parent_context = previous_parent_context
        end

        execution_parent_proxy.children
      else
        # at this point the children should be completely built
        @current_parent_context.children.concat(slot_content)
      end
    end

    # TODO the implementation is simple, but reasoning about is quite
    # complex imo. The main reason is that `yield_components` has no
    # access to the block. Of course that could be solved by making
    # it an instance variable. Might be nicer if we could do
    # `def response(&block)`
    # Also:
    # * right now only works with one yield_components, would break with
    #  two that might be nice to raise/warn about
    def yield_components
      @yield_components_to = @current_parent_context
    end

    private

    ## ------------------------ Also Rendering ---------------------
    # common attribute handling for tags/components
    def set_tag_attributes
      default_attributes = {
        id: component_id,
        class: options[:class]
       }
       unless options[:attributes].nil?
         default_attributes.merge!(options[:attributes])
       end

       @tag_attributes = default_attributes
    end
  end
end
