class Components::LegacyViews::Pages::Collection < Matestack::Ui::Component

  requires :collection_config

  def response
    heading size: 2, text: 'My Collection'
    filter
    async rerender_on: "#{context.collection_config.id}-update", id: 'async-collection' do
      content
    end
  end

  private

  def filter
    collection_filter context.collection_config.config do
      form_input key: :title, type: :text, placeholder: "Filter by Title", label: 'Title', id: 'title-filter'
      button text: "filter", type: "submit"
      collection_filter_reset do
        button text: "reset"
      end
    end
  end

  def content
    collection_content context.collection_config.config do
      ul do
        context.collection_config.data.each do |dummy|
          li text: dummy.title
        end
      end
    end
  end

end
