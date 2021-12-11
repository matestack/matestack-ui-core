# used in specs only, look for the demo app here: ./demo/app.rb

class App < Matestack::Ui::App

  def response
    yield
  end

end
