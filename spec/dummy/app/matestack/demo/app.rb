class Demo::App < Matestack::Ui::App

  def response
    h1 'App'
    yield
  end

end
