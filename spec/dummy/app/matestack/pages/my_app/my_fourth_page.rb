class Pages::MyApp::MyFourthPage < Page::Cell::Page

  def prepare
    @dummy_model = DummyModel.new
  end

  def response
    components {
      heading size: 2, text: "Dummy Model Form:"
      form my_form_config, :include do
        form_input key: :title, type: :text, placeholder: "title"
        pg
        form_submit do
          button text: "Submit me!"
        end
      end
      pg
      async show_on: "form_has_errors", hide_after: 5000 do
        plain "Data could not be submitted, please check form"
      end
      pg
      async rerender_on: "form_succeeded" do
        heading size: 2, text: "Dummy Models:"
        ul do
          DummyModel.all.each do |dummy_model|
            li do
              plain dummy_model.title
            end
          end
        end
      end
    }
  end

  def my_form_config
    {
      for: @dummy_model,
      method: :post,
      path: :form_action_path,
      success: {
        emit: "form_succeeded"
      },
      failure: {
        emit: "form_has_errors"
      }
    }
  end

end
