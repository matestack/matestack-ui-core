class Components::LegacyViews::Pages::Isolated < Matestack::Ui::IsolatedComponent

  def response
    div class: 'my-isolated' do
      plain DateTime.now.strftime('%Q')
    end
    hr
    async rerender_on: 'async_update_time', id: 'foobar' do
      paragraph id: 'async-time', text: DateTime.now.strftime('%Q')
    end
  end

  def authorized?
    true
  end

end