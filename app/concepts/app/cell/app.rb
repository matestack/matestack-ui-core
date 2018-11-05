module App::Cell
  class App < Trailblazer::Cell
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
    include ::Basemate::Ui::Core::ApplicationHelper
    include Shared::Utils::ToCell
    # include ::Rails.application.routes.url_helpers

    view_paths << "#{Basemate::Ui::Core::Engine.root}/app/concepts"

    def initialize(model=nil, options={})
      super
      @nodes = {}
      @cells = {}
      @page_block = nil
      @page_id = ""
      setup
    end

    def setup
      true
    end

    def prepare
      true
    end

    def show(page_id, page_nodes, &block)
      @page_id = page_id
      @page_nodes = page_nodes
      prepare
      response
      render(view: :app, &block)
    end

    def page_nodes
      @page_nodes
    end

    def components(&block)
      @nodes = ::App::Utils::AppNode.build(self, &block)

      @nodes.each do |key, node|
        @cells[key] = to_cell(key, node["component_name"], node["config"], node["argument"], node["components"])
      end
    end

    def partial(&block)
      ::App::Utils::AppNode.build(self, &block)
    end

  end
end
