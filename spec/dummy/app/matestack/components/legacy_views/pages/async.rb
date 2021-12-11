# used in specs

class Components::LegacyViews::Pages::Async < Matestack::Ui::Component

  def response
    div id: 'foobar' do
      paragraph 'Im a custom component'
      async rerender_on: 'update_time', id: 'async-legacy-integratable' do
        paragraph I18n.l(DateTime.now)
      end
      onclick emit: 'update_time' do
        button 'Click me!'
      end
    end
  end

end
