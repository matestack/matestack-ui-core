class Demo::Pages::RelationForm < Matestack::Ui::Page

  def prepare
    if context[:params][:id].nil?
      @my_model = DummyModel.new
    else
      @my_model = DummyModel.find context[:params][:id]
      @new_child = DummyModel.dummy_child_models.new
    end
  end

  def response
    heading size: 2, text: "Relation Form"

    if @my_model.new_record?
      parent_form
    else
      parent_values
      children
    end
  end

  def parent_form
    form parent_form_config, :include do
      form_input key: :title, type: :text
      form_submit do
        button text: "save"
      end
    end
  end

  def parent_values
    heading size: 3, text: @my_model.title
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
    plain "children"
  end

end
