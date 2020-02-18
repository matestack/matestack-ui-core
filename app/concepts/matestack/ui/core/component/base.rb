module Matestack::Ui::Core::Component
  class Base < Trailblazer::Cell
    include Matestack::Ui::Core::Cell
    include Matestack::Ui::Core::ApplicationHelper
    include Matestack::Ui::Core::ToCell
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

    attr_reader :children

    def initialize(model=nil, options={})
      super
      @component_config = options.except(:context, :children, :url_params, :included_config)
      # TODO does this always need to be here?
      @url_params = options[:url_params]&.except(:action, :controller, :component_key)
      @component_key = options[:component_key]
      @children_cells = {}
      # #context is defined in `Cell::ViewModel`
      # TODO do we always need this?
      @controller_context = context&.fetch(:controller_context, nil)
      # @model also exists with the same content? Is there any reason we wouldn't
      # wanna use it instead of @argument? There's even a `model` accessor for it
      # TODO
      @argument = model
      @nodes = {}
      @cells = {}
      @included_config = options[:included_config]
      @cached_params = options[:cached_params]
      @rerender = false
      @options = options

      # DSLish
      @children = []
      @current_parent_context = self

      # set me up
      set_tag_attributes
      setup
      generate_children_cells
      validate_options
    end

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
      child = child_class.new(*args)

      # TODO nicer interface
      @current_parent_context.children << child

      if block
        begin
          @current_parent_context = child
          instance_eval(&block)
        ensure
          @current_parent_context = self
        end
      end

      child
    end

    ## NEW TOBI HTML METHODS
    def to_html
      show
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

    ## ------------------ Rendering ----------------
    # Invoked by Cell::ViewModel from Rendering#call
    #
    # TODO: Mental node get the different renderings into their own
    # distinct renderers like StaticRenderer, DynamicRenderer etc.
    def show(&block)
      if respond_to? :prepare
        prepare
      end
      if respond_to? :response
        response &block
        if @static
          render :response
        else
          if @rerender
            render :response_dynamic
          else
            render :response_dynamic_without_rerender
          end
        end
      else
        if @static
          render(view: :static, &block)
        else
          if @rerender
            render(view: :dynamic, &block)
          else
            render(view: :dynamic_without_rerender, &block)
          end
        end
      end
    end

    def render_children
      render(view: :children)
    end

    def render_content(&block)
      if respond_to? :prepare
        prepare
      end
      if respond_to? :response
        response &block
          render :response
      else
        # render(view: self.class.name.split("::")[-1].downcase.to_sym) do
        render do
          render_children
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
      if respond_to? :prepare
        prepare
      end

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
    def components(&block)
      @nodes = Matestack::Ui::Core::ComponentNode.build(self, nil, &block)

      @nodes.each do |key, node|
        @cells[key] = to_cell("#{@component_key}__#{key}", node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
      end
    end

    # BEGIN PROBABLY WITH DOCILE WE DON'T NEED THESE TWO ANYMORE WAT WAT
    def partial(&block)
      return Matestack::Ui::Core::ComponentNode.build(self, nil, &block)
    end

    def slot(&block)
      return Matestack::Ui::Core::ComponentNode.build(self, nil, &block)
    end
    # END PROBABLY WITH DOCILE WE DON'T NEED THESE TWO ANYMORE WAT WAT

    private

    ## ------------------------ Also Rendering ---------------------
    def generate_children_cells
      unless options[:children].nil?
        #needs refactoring --> in some cases, :component_key, :children, :origin_url, :url_params, :included_config get passed into options[:children] which causes errors
        #quickfix: except them from iteration
        options[:children].except(:component_key, :children, :origin_url, :url_params, :included_config).each do |key, node|
          @children_cells[key] = to_cell("#{@component_key}__#{key}", node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
        end
      end
    end

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

    def dynamic_tag_attributes
       attrs = {
         "is": @component_class,
         "ref": component_id,
         ":params":  @url_params.to_json,
         ":component-config": @component_config.to_json,
         "inline-template": true,
       }
       attrs.merge!(options[:attributes]) unless options[:attributes].nil?
       return attrs
    end

  end
end
