module App::Cell
  class App < Trailblazer::Cell
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Haml
    include ::Basemate::Ui::Core::ApplicationHelper
    include Shared::Utils::ToCell

    view_paths << "#{Basemate::Ui::Core::Engine.root}/app/concepts"

    def initialize(model=nil, options={})
      super
      setup
    end

    def setup
      true
    end

    def show(&block)
      render(view: :app, &block)
    end

  end
end
