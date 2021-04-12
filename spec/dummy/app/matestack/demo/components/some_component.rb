class Demo::Components::SomeComponent < Matestack::Ui::Component

  required :name

  def response
    h2 ctx.name
    5.times do |i|
      paragraph i
    end
  end

end