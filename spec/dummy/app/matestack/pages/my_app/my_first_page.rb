class Pages::MyApp::MyFirstPage < Matestack::Ui::Page

  def response
    components {
      heading size: 2, text: "This is Page 1"

      div id: "some-id", class: "some-class" do
        plain "hello from page 1"
      end
    }
  end


end
