require_dependency "cell/partial"

module Html::Cell
  class Html < Component::Cell::Dynamic

    include Cell::ViewModel::Partial

    view_paths << "#{::Rails.root}/app/views"

    def include_partial(&block)
      render partial: "#{options[:path]}" do
        capture(&block)
      end
    end

  end
end
