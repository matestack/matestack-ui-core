class Demo::Components::Test < Matestack::Ui::Component

  optional :name

  def response
    div do
      div do
        plain ctx.name
      end
    end
    div do
      yield
    end
  end

  def content
    'bar'
  end

end