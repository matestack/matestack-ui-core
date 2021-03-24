class Demo::Components::IsolateTest < Matestack::Ui::VueJs::Components::Isolated

  def response
    div do
      h2 'Isolate test'
      paragraph Time.now
    end
  end

  protected

  def authorized?
    true
  end

end