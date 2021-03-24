require 'rails_helper'

describe 'Input Component', type: :feature, js: true do
  include Utils

  it 'renders a input' do
    matestack_render do
      select
    end
    expect(page).to have_selector('select')
  end

  it 'is possible to render options wrapped in a select' do
    matestack_render do
      select id: "foo", class: "bar" do
        option label: 'Option 1', value: '1', selected: true
        option label: 'Option 2', value: '2'
        option label: 'Option 3', value: '3'
      end
    end
    static_output = page.html
    expected_static_output = <<~HTML
      <select id="foo" class="bar">
        <option  label="Option 1" value="1" selected="selected"></option>
        <option  label="Option 2" value="2"></option>
        <option  label="Option 3" value="3"></option>
      </select>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
