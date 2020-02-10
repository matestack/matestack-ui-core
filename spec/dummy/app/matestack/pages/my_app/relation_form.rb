class Pages::MyApp::RelationForm < Matestack::Ui::Page

  def prepare
    if context[:params][:id].nil?
      @my_model = DummyModel.new
    else
      @my_model = DummyModel.find context[:params][:id]
      @new_child = DummyModel.dummy_child_models.new
    end
  end

  def response
    components {
      heading size: 2, text: "Relation Form"

      if @my_model.new_record?
        partial :parent_form
      else
        partial :parent_values
        partial :children
      end
    }
  end

  def parent_form
    partial {
      form parent_form_config, :include do
        form_input key: :title, type: :text
        form_submit do
          button text: "save"
        end
      end
    }
  end

  def parent_values
    partial {
      heading size: 3, text: @my_model.title
    }
  end

  def parent_form_config
    {
      for: @my_model,
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

  def children
    partial {
      plain "children"
    }
  end



end
