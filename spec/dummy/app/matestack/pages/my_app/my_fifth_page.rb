class Pages::MyApp::MyFifthPage < Page::Cell::Page

  def prepare
    @dummy_models = DummyModel.all
  end

  def response
    components {
      heading size: 2, text: "Dummy Models"
      async rerender_on: "test_model_created" do
        ul do
          @dummy_models.each do |dummy_model|
            li do
              plain dummy_model.title
            end
          end
        end
      end
    }
  end

end
