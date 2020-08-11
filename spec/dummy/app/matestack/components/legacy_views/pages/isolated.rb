class Components::LegacyViews::Pages::Isolated < Matestack::Ui::IsolatedComponent

  def response
    div class: 'my-isolated' do
      plain I18n.l(DateTime.now)
    end
  end

  def authorized?
    true
  end

end