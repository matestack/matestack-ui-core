class Demo::Components::MyIsolatedComponent < Matestack::Ui::IsolatedComponent

  def response
    plain "demo isolated component"
  end

  def authorized?
    true
  end

  def loading_state_element
    plain "loading..."
  end

end
