module Matestack::Ui::Core::Component
  class Dynamic < Trailblazer::Cell

    include ActionView::Helpers::ActiveModelHelper
    include ActionView::Helpers::ActiveModelInstanceTag
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::AssetUrlHelper
    include ActionView::Helpers::AtomFeedHelper
    include ActionView::Helpers::CacheHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::CspHelper
    include ActionView::Helpers::CsrfHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::DebugHelper
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::RecordTagHelper
    # include ActionView::Helpers::RenderingHelper
    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::UrlHelper
    include ::Cell::Haml
    include Matestack::Ui::Core::ApplicationHelper
    include Matestack::Ui::Core::ToCell

    view_paths << "#{Matestack::Ui::Core::Engine.root}/app/concepts"
    view_paths << "#{::Rails.root}/app/matestack"

    extend ViewName::Flat

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

    def initialize(model=nil, options={})
      super
      @component_config = options.except(:context, :children, :url_params, :included_config)
      @url_params = options[:url_params].except(:action, :controller, :component_key)
      @component_key = options[:component_key]
      @children_cells = {}
      @controller_context = context[:controller_context]
      @argument = model
      @static = false
      @nodes = {}
      @cells = {}
      @included_config = options[:included_config]
      @cached_params = options[:cached_params]
      @rerender = false
      @options = options
      set_tag_attributes
      setup
      generate_component_name
      generate_children_cells
      validate_options
    end

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

    def setup
      true
    end

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

    def components(&block)
      @nodes = Matestack::Ui::Core::ComponentNode.build(self, nil, &block)

      @nodes.each do |key, node|
        @cells[key] = to_cell(key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
      end
    end

    def partial(&block)
      return Matestack::Ui::Core::ComponentNode.build(self, nil, &block)
    end

    def slot(&block)
      return Matestack::Ui::Core::ComponentNode.build(self, nil, &block)
    end

    def get_children
      return options[:children]
    end

    def to_css_class(symbol)
      symbol.to_s.gsub("_", "-")
    end

    def modifiers
      result = []
      return unless defined? self.class::OPTIONS
      self.class::OPTIONS.select{ |modifer_key, modifier_options|
        modifier_options[:css_modifier] == true
      }.each do |modifer_key, modifier_options|
        if !options[modifer_key] == false || modifier_options[:default] == true
          result << "#{to_css_class(self.class::CSSClASS)}--#{to_css_class(modifer_key)}"
        end
      end
      result.join(" ")
    end

    private

      def generate_children_cells
        unless options[:children].nil?
          #needs refactoring --> in some cases, :component_key, :children, :origin_url, :url_params, :included_config get passed into options[:children] which causes errors
          #quickfix: except them from iteration
          options[:children].except(:component_key, :children, :origin_url, :url_params, :included_config).each do |key, node|
            @children_cells[key] = to_cell("#{@component_key}__#{key}", node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
          end
        end
      end

      def generate_component_name
        name_parts = self.class.name.split("::")
        module_name = name_parts[0]
        if module_name == "Components"
          name_parts[0] = "Custom"
        end
        if name_parts.count > 1
          if name_parts.include?("Cell")
            name = name_parts[0] + name_parts[1]
            if name_parts[0] == name_parts[2]
              name = name_parts[0] + name_parts[1]
              @component_class =  name.underscore.gsub("_", "-")
            else
              name = name_parts[0] + name_parts[2] + name_parts[1]
              @component_class = name.underscore.gsub("_", "-")
            end
          else
            if name_parts[-2] == name_parts[-1]
              @component_class = name_parts[0..-2].join("-").downcase
            else
              @component_class = name_parts.join("-").downcase
            end
          end
        else
          name = name_parts[0]
          @component_class = name.underscore.gsub("_", "-")
        end
        @component_name = @component_class
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
