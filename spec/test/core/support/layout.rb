# used in specs only, look for the demo app here: ./demo/app.rb

class Layout < Matestack::Ui::Layout

  def response
    yield
  end

end
