# used in specs

class Components::LegacyViews::Pages::Onclick < Matestack::Ui::Component

  def response
    onclick emit: 'update_time' do
      button 'Click me!'
    end
    toggle show_on: 'update_time', hide_after: 1000, id: 'async-onclick' do
      plain 'clicked'
    end
  end

end
