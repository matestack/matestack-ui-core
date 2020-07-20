class Components::LegacyViews::Pages::Collection < Matestack::Ui::StaticComponent
  requires :collection_config

  def response
    heading size: 2, text: 'My Collection'
    filter
    async rerender_on: "#{collection_config.id}-update", id: 'async-collection' do
      content
    end
  end

  private

  def filter
    collection_filter collection_config.config do 
      collection_filter_input key: :title, type: :text, placeholder: "Filter by Title", label: 'Title', id: 'title-filter'
      collection_filter_submit do
        button text: "filter"
      end
      collection_filter_reset do
        button text: "reset"
      end
    end
  end

  def content
    collection_content collection_config.config do
      ul do
        collection_config.data.each do |dummy|
          li text: dummy.title
        end
      end
    end
  end

end