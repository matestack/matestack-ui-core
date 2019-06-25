require_dependency "cell/partial"

module Matestack::Ui::Core::Html
  class Html < Matestack::Ui::Core::Component::Dynamic

    include Cell::ViewModel::Partial

    view_paths << "#{::Rails.root}/app/views"

    def include_partial(&block)
      render partial: "#{options[:path]}" do
        capture(&block)
      end
    end

  end
end
