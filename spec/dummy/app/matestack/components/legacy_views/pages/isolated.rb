# used in specs

class Components::LegacyViews::Pages::Isolated < Matestack::Ui::IsolatedComponent

  def response
    time = DateTime.now.strftime('%Q')
    div class: 'my-isolated' do
      plain time
    end
    hr
    async rerender_on: 'async_update_time', id: 'foobar' do
      paragraph time, id: 'async-time'
    end
  end

  def authorized?
    true
  end

end
