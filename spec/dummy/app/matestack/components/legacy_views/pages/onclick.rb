class Components::LegacyViews::Pages::Onclick < Matestack::Ui::StaticComponent

  def response
    onclick emit: 'update_time' do
      button text: 'Click me!'
    end
    async show_on: 'update_time', hide_after: 1000, id: 'async-onclick' do
      plain 'clicked'
    end
  end

end