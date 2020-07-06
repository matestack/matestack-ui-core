class Demo::Pages::CreateAndShow < Matestack::Ui::Page

  def prepare
    @dummy_model = DummyModel.new
  end

  def response
    components {
      heading size: 2, text: "Create"

      heading size: 3, text: "Dummy Model Form:"

      form my_form_config, :include do
        form_input key: :title, type: :text, placeholder: "title"
        br
        br
        form_submit do
          button text: "Submit me!"
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
        transition: {
          follow_response: true
        }
      },
      failure: {
        emit: "form_has_errors"
      }
    }
  end

end
