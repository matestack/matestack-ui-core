class Components::Demo::Component < Matestack::Ui::DynamicComponent

  def response
    components {
      div id: "my-component" do
        heading size: 2, text: @options[:heading_text]
        button attributes: {"@click": "callApi()"} do
          plain "Call API"
        end
        ul do
          li attributes: {"v-for": "item in data"} do
            plain "{{item}}"
          end
        end
      end
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
        emit: "form_succeeded"
      },
      failure: {
        emit: "form_has_errors"
      }
    }
  end

end
