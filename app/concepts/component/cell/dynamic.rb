module Component::Cell
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
    # include ActionView::Helpers::UrlHelper
    # include ActionView::Helpers::TranslationHelper
    include ::Cell::Haml
    include ::Basemate::Ui::Core::ApplicationHelper
    include Shared::Utils::ToCell

    view_paths << "#{Basemate::Ui::Core::Engine.root}/app/concepts"

    def initialize(model=nil, options={})
      super
      @component_config = options.except(:context, :children, :url_params)
      @url_params = options[:url_params].except(:action, :controller, :component_key)
      @component_key = options[:component_key]
      @children_cells = {}
      @controller_context = context[:controller_context]
      @argument = model
      @static = false
      generate_component_name
      generate_children_cells
      setup
    end

    def self.static
      @static = true
    end

    def setup
      true
    end

    def show(&block)
      render(view: :dynamic, &block)
    end

    def render_children
      render(view: :children)
    end

    def render_content(&block)
      render do
        render_children
      end
    end

    def component_id
      options[:id] ||= @component_key
    end

    def js_action name, arguments
      argumentString = arguments.join('", "')
      argumentString = '"' + argumentString + '"'
      [name, '(', argumentString, ')'].join("")
    end

    def navigate_to path
      js_action("navigateTo", [path])
    end

    private

      def generate_children_cells
        unless options[:children].nil?
          options[:children].each do |key, node|
            @children_cells[key] = to_cell("#{@component_key}__#{key}", node["component_name"], node["config"], node["argument"], node["components"])
          end
        end
      end

      def generate_component_name
        name_parts = self.class.name.split("::")
        name = name_parts[0] + name_parts[1]
        if name_parts[0] == name_parts[2]
          name = name_parts[0] + name_parts[1]
          @component_class =  name.underscore.gsub("_", "-")
        else
          name = name_parts[0] + name_parts[2] + name_parts[1]
          @component_class = name.underscore.gsub("_", "-")
        end
        @component_name = @component_class.gsub("-cell", "")
      end

  end
end
