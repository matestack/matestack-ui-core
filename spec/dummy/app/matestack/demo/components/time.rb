class Demo::Components::Time < Matestack::Ui::Component

  def response
    div do
      h1 'Pushed Time'
      paragraph Time.now
    end
  end

end