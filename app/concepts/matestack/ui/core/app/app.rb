module Matestack::Ui::Core::App
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
    # include ActionView::Helpers::RenderingHelper
    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::UrlHelper
    include ::Cell::Haml
    include Matestack::Ui::Core::ApplicationHelper
    include Matestack::Ui::Core::ToCell
    # include ::Rails.application.routes.url_helpers

    view_paths << "#{Matestack::Ui::Core::Engine.root}/app/concepts"

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

      return modified_prefixes
    end

    def self.views_dir
      return ""
    end

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
      @nodes = Matestack::Ui::Core::AppNode.build(self, &block)

      @nodes.each do |key, node|
        @cells[key] = to_cell(key, node["component_name"], node["config"], node["argument"], node["components"], nil, node["cached_params"])
      end
    end

    def partial(&block)
      Matestack::Ui::Core::AppNode.build(self, &block)
    end

  end
end
