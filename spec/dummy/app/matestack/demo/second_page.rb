class Demo::SecondPage < Matestack::Ui::Page

  def response
    h1 'Second Page'
    transition path: root_path do
      button 'First Page'
    end

    m_form method: :post, for: :test, path: action_path, success: { emit: :success } do
      form_input key: :foo, type: :text, label: 'Test'
      form_textarea key: :textarea, label: 'Test'
      form_checkbox key: :bar, options: [1,2,3]
      form_checkbox key: :xyz, label: 'Check'
      form_radio key: :radio, options: [1,2,3]
      form_select key: :select, options: [1,2,3]
      form_select key: :multi, options: [1,2,3], multiple: true
      # form_select key: :preselect, options: {foo: 'Hallo', bar: 'Hello'}, disabled_options: { foo: 'Hallo' }, placeholder: 'no'
      button 'Submit'
      button 'Nicht submit', type: :button
    end

    form do
      input type: :text, required: true
      button 'Speichern'
    end

    toggle show_on: :success, hide_after: 1000 do
      div 'Erfolgreich submitted'
    end
  end

end