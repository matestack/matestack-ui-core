module Matestack::Ui::Core::Component
  class Base < Trailblazer::Cell
    include Matestack::Ui::Core::Cell
    include Matestack::Ui::Core::HasViewContext

    # probably eed to remove for other tests to be green again
    include Matestack::Ui::Core::DSL

    view_paths << "#{Matestack::Ui::Core::Engine.root}/app/concepts"
    view_paths << "#{::Rails.root}/app/matestack"

    extend ViewName::Flat

    # TODO: isolate available functions to bare minimum as everything is a
    # potential conflict with a user defined method?!
    # Not in this ticket, but open an issue once we get there?
    # That especially includes all those modules, accidentally overriding one
    # method might break the whole thing.

    attr_reader :children, :parent

    def initialize(parent = nil, model = nil, options = {})
      super(model, options)
      # @model also exists with the same content? Is there any reason we wouldn't
      # wanna use it instead of @argument? There's even a `model` accessor for it
      # TODO
      @argument = model
      @options = options

      # TODO works around a semantic where if just a hash is passed apparently
      # those are the options
      @options = model.dup if @options.empty? && model.is_a?(Hash)

      # DSL-relevant
      @children = []
      @parent = parent
      @current_parent_context = @parent || self

      # TODO: everything beyond this point is probably not needed for the
      # Page subclass

      # TODO: potentially only used in form like components
      @included_config = options[:included_config]
      # TODO: only relevant to isolate
      @cached_params = options[:cached_params]

      # TODO seemingly never accessed? (at least by us)
      # #context is defined in `Cell::ViewModel`
      @controller_context = context&.fetch(:controller_context, nil)

      # Options for seemingly advanced functionality
      @component_config = options.except(:context, :children, :url_params, :included_config)
      @url_params = options[:url_params]&.except(:action, :controller, :component_key)
      @component_key = options[:component_key]

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

    # NEW DSL RELATED METHODS
    def add_child(child_class, *args, &block)
      # can't do a splat first followed by a default argument in Ruby,
      # as semantics are unclear. Could put the block as a second argument but
      # that'd make the DSL weird if used this way:
      # add_child Class, proc { ... }, text: "lol"
      #  vs
      # add_child Class, {text: "lol"}, proc { ... }
      # block = args.pop if args.last.is_a?(Proc) || args.last.nil?

      # TODO nicer interface
      child = child_class.new(@current_parent_context, *args)
      @current_parent_context.children << child

      child.prepare

      child.response if child.respond_to?(:response)

      if block
        begin
          @current_parent_context = child
          instance_eval(&block)
        ensure
          @current_parent_context = child.parent
        end
      end

      child
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
    # TODO: Mental node get the different renderings into their own
    # distinct renderers like StaticRenderer, DynamicRenderer etc.
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

    def render_child_component component_key, current_search_keys_array
      prepare

      response

      if current_search_keys_array.count > 1
        if @nodes.dig(*current_search_keys_array) == nil
          rest = []
          while @nodes.dig(*current_search_keys_array) == nil
            rest << current_search_keys_array.pop
          end
          node = @nodes.dig(*current_search_keys_array)
          cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
          begin
            return cell.render_child_component component_key, rest.reverse[1..-1]
          rescue
            return cell.render_content
          end
        else
          node = @nodes.dig(*current_search_keys_array)
          cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
          return cell.render_content
        end
      else
        node = @nodes[current_search_keys_array[0]]
        cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
        return cell.render_content
      end
    end

    ## ---------------------- DSL ------------------------------
    # compatibility layer to old-school (not needed anymore)
    def components(&block)
      instance_eval &block
    end

    # TODO: partial is weird, I highly recommend removin it
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

    def slot(&block)
      return Matestack::Ui::Core::ComponentNode.build(self, nil, &block)
    end

    private

    ## ------------------------ Also Rendering ---------------------
    def set_tag_attributes
      default_attributes = {
        "id": component_id,
        "class": options[:class]
       }
       unless options[:attributes].nil?
         default_attributes.merge!(options[:attributes])
       end

       @tag_attributes = default_attributes
    end
  end
end
