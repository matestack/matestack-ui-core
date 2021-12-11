class Demo::Components::StaticComponent < Matestack::Ui::Component

  required :foo

  def response
    plain "A simple Static Component with given input foo: #{context.foo}"
  end

end
