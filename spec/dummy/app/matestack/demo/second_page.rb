class Demo::SecondPage < Matestack::Ui::Page

  def response
    h1 'Second Page'
    transition path: root_path do
      button 'First Page'
    end

    matestack_form method: :post, for: :test, path: action_path, success: { emit: :success } do
      form_input key: :foo, tsype: :text, label: 'Test', class: 'foobar'
      form_textarea key: :textarea, label: 'Test', class: 'foobar'
      form_checkbox key: :bar, options: [1,2,3], class: 'foobar'
      form_checkbox key: :xyz, label: 'Check', class: 'foobar'
      form_radio key: :radio, options: [1,2,3], class: 'foobar'
      form_select key: :select, options: [1,2,3], class: 'foobar'
      form_select key: :multi, options: [1,2,3], multiple: true, class: 'foobar'
      form_select key: :preselect, options: {foo: 'Hallo', bar: 'Hello'}, disabled_options: { foo: 'Hallo' }, placeholder: 'no'
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
