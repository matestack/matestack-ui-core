class MatestackWrapperApp < Matestack::Ui::App
  def response
    yield_page
  end
end