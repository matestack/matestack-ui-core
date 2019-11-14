class Pages::MyApp::InlineEdit < Matestack::Ui::Page

  def prepare
    @my_model = DummyModel.last
  end

  def response
    components {
      heading size: 2, text: "Inline Edit"

      if @my_model.nil?
        plain "please create a model on Page 4"
      else
        partial :show_value
        partial :show_form
      end
    }
  end

  def show_value
    partial {
      async rerender_on: "item_updated", show_on: "item_updated", hide_on: "update_item", init_show: true do
        onclick emit: "update_item" do
          plain @my_model.title
          plain "(click me)"
        end
      end
    }
  end

  def show_form
    partial {
      async rerender_on: "item_updated", show_on: "update_item", hide_on: "item_updated" do
        form some_form_config, :include do
          form_input key: :title, type: :text
          form_submit do
            button text: "save"
          end
        end
        onclick emit: "item_updated" do
          button text: "abort"
        end
      end
    }
  end

  def some_form_config
    {
      for: @my_model,
      method: :post,
      path: :inline_form_action_path,
      params: {
        id: @my_model.id
      },
      success:{
        emit: "item_updated"
      }
    }
  end


end
