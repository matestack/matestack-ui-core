class Demo::Pages::MyFourthPage < Matestack::Ui::Page

  def prepare
    @dummy_model = DummyModel.new
  end

  def response
    heading size: 2, text: "This is Page 4"

    heading size: 3, text: "Dummy Model Form:"

    form my_form_config, :include do
      form_input key: :title, type: :text, placeholder: "title", required: true
      form_input key: :description, type: :text, placeholder: "Description", label: 'Description', attributes: { required: true }
      br
      paragraph text: 'Checkbox'
      # form_checkbox key: :status, label: 'foobar'
      form_radio key: :old_status, options: [0, 1], label: 'foobar', init: 0
      br
      form_radio key: :status, options: { 'Aktiv': 1, 'Inaktiv': 0 }, label: 'foobar'
      br
      form_select key: :status, options: { 'Aktiv': 1, 'Inaktiv': 0 }, label: 'Select'
      br
      form_select key: :status, options: (1..20).to_a, label: 'Select', disabled_values: (1..5).to_a, placeholder: 'foobar'
      br
      form_select key: :foobar, options: (1..20).to_a, label: 'Select', multiple: true
      # br
      # form_checkbox key: :bar, options: (1..20).to_a, label: 'Select'
      # form_input key: :title, type: :text, placeholder: "title", required: true
      # form_input key: :description, type: :text, placeholder: "Description", label: 'Description', attributes: { required: true }
      # br
      form_submit do
        button text: "Submit me!"
      end
    end

    br

    toggle show_on: "form_has_errors", hide_after: 5000 do
      plain "Data could not be submitted, please check form"
    end

    br

    async id: 'dummy-model-list', rerender_on: "form_succeeded" do
      heading size: 3, text: "Dummy Models:"
      ul do
        DummyModel.all.each do |dummy_model|
          li do
            plain "#{dummy_model.title} - Status #{dummy_model.status}"
          end
        end
      end
    end
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
