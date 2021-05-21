# used within specs only
class App < Matestack::Ui::App

  def response
    yield
  end

end
