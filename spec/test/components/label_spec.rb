require 'rails_helper'

describe 'Label Component', type: :feature, js: true do
  include Utils

  it 'Example 1' do
    matestack_render do
      # simple label
      label 'I am simple'
      # enhanced label
      label id: 'my-id', for: 'label for something', class: 'my-class' do
        plain 'I am enhanced'
      end
      # with form attribute
      label 'Label for Form1', id: 'form_label', for: "form", form: 'form1' 
    end
    static_output = page.html
    expected_static_output = <<~HTML
      <label>I am simple</label>
      <label id="my-id" for="label for something" class="my-class" >I am enhanced</label>
      <label id="form_label" for="form" form="form1">Label for Form 1</label>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
