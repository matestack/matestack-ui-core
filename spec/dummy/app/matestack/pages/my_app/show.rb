class Pages::MyApp::Show < Matestack::Ui::Page

  def prepare
    @dummy_model = DummyModel.find context[:params][:id]
  end

  def response
    components {
      heading size: 2, text: "Show"

      plain @dummy_model.inspect
    }
  end

end
