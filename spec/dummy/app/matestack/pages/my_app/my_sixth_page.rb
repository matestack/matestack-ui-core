class Pages::MyApp::MySixthPage < Page::Cell::Page

  def prepare
    @dummy_models = DummyModel.all
  end

  def response
    components {
      async show_on: "my_custom_event", hide_after: "2000" do
        plain "called API!"
      end
      custom_demo_component heading_text: "Custom Vue.js Component"
    }
  end

end
