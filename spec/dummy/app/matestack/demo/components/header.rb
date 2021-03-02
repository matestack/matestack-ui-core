class Demo::Components::Header < Matestack::Ui::Component

  def response
    h1 'This is a header'
    slot slots[:first]
    paragraph 'Juhu !!!'
    slot slots[:second] 
  end

end