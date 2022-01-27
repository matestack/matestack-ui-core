class MatestackWrapperLayout < Matestack::Ui::Layout
  def response
    app_body
    yield
  end

  def app_body

  end

end
