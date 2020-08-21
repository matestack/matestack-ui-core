class Components::LegacyViews::Pages::Async < Matestack::Ui::StaticComponent

  def response
    div id: 'foobar' do
      paragraph text: 'Im a custom component'
      async rerender_on: 'update_time', id: 'async-legacy-integratable' do 
        paragraph text: I18n.l(DateTime.now)
      end
      onclick emit: 'update_time' do
        button text: 'Click me!'
      end
    end
  end

end