class Components::LegacyViews::Pages::Form < Matestack::Ui::Component

  def response
    matestack_form form_config do
      form_input key: :title, type: :text, label: 'Title', id: 'title'
      button 'Save'
    end
    async rerender_on: 'form_success', id: 'async-dummy-list' do
      ul do
        DummyModel.all.order(title: :asc).each do |dummy|
          li dummy.title
        end
      end
    end
  end

  private

  def form_config
    {
      for: DummyModel.new,
      method: :post,
      path: legacy_views_create_path,
      success: {
        emit: 'form_success',
      },
      failure: {
        emit: 'form_failure',
      },
    }
  end

end