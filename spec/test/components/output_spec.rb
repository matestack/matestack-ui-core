require 'rails_helper'

describe 'Output component', type: :feature, js: true do
  include Utils

  it 'Renders a simple and enhanced output tag on a page' do
    matestack_render do
      # Without content
      output name: 'x', for: 'a b'
      # Only content
      output 'Only content'
      # All attributes
      output id: 'my-id', class: 'my-class', name: 'x', for: 'a b', form: 'form_id' do
        plain 'All attributes'
      end
    end
    static_output = page.html
    expected_static_output = <<~HTML
      <output name="x" for="a b"></output>
      <output>Only content</output>
      <output id="my-id" class="my-class" name="x" for="a b" form="form_id" >All attributes</output>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
