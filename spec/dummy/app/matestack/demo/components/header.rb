class Demo::Components::Header < Matestack::Ui::Component

  optional :user

  def response
    h1 'This is a header'
    [1,2].each do |number|
      slot slots[:first], number
    end
    slot slots[:user]
    div do
      h2 ctx.user
    end
  end

end