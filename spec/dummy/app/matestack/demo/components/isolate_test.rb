class Demo::Components::IsolateTest < Matestack::Ui::VueJs::Components::Isolated

  def response
    div do
      h2 'Isolate test'
      paragraph Time.now
      paragraph public_options.to_json
    end
  end

  protected

  def authorized?
    true
  end

end