class Pages::MyApp::MyFirstPage < Matestack::Ui::Page

  def prepare
    @my_model = DummyModel.last
  end

  def response
    components {
      heading size: 2, text: "This is Page 1"

      div id: "some-id", class: "some-class" do
        plain "hello from page 1"
      end
    }
  end


end
