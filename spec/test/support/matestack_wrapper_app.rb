class MatestackWrapperApp < Matestack::Ui::App
  def response
    yield
  end
end