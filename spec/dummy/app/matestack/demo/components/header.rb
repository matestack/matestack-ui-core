class Demo::Components::Header < Matestack::Ui::Component

  optional :user

  def response
    h1 'This is a header'
    slot slots[:first]
    paragraph 'Juhu !!!'
    slot slots[:second] 
    div do
      h2 ctx.user
    end
  end

end