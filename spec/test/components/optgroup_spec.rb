require 'rails_helper'

describe 'Optgroup component', type: :feature, js: true do
  include Utils

  it 'Renders a optgroup tag on a page' do
    matestack_render do
      # Just the tag
      optgroup
      # The tag with a label
      optgroup label: 'Optgroup'
      # Optgroup tag without label but sub-components
      optgroup do
        option 'Option A'
        option 'Option B'
        option 'Option C'
      end
      # Simple optgroup
      optgroup label: 'Simple Group' do
        option 'Option D'
        option 'Option E'
        option 'Option F'
      end
      # Enhanced optgroups
      optgroup label: 'Enabled Group 1', class: 'enabled' do
        option 'Option G'
        option 'Option H'
        option 'Option I'
      end
      optgroup label: 'Disabled Group 2', disabled: true, id: 'disabled' do
        option 'Option J'
        option 'Option K'
        option 'Option L'
      end
      optgroup label: 'Not Disabled Group 3', disabled: false, class: 'group', id: 'not-disabled' do
        option 'Option M'
        option 'Option N'
        option 'Option O'
      end
    end
    static_output = page.html
    expected_static_output = <<~HTML
      <optgroup></optgroup>
      <optgroup label="Optgroup"></optgroup>
      <optgroup>
        <option>Option A</option>
        <option>Option B</option>
        <option>Option C</option>
      </optgroup>
      <optgroup label="Simple Group">
        <option>Option D</option>
        <option>Option E</option>
        <option>Option F</option>
      </optgroup>
      <optgroup label="Enabled Group 1" class="enabled">
        <option>Option G</option>
        <option>Option H</option>
        <option>Option I</option>
      </optgroup>
      <optgroup label="Disabled Group 2" disabled="disabled" id="disabled">
        <option>Option J</option>
        <option>Option K</option>
        <option>Option L</option>
      </optgroup>
      <optgroup label="Not Disabled Group 3" class="group" id="not-disabled">
        <option>Option M</option>
        <option>Option N</option>
        <option>Option O</option>
      </optgroup>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
