require_relative '../support/utils'
include Utils

describe 'Optgroup component', type: :feature, js: true do

  it 'Renders a optgroup tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
          # Just the tag
          optgroup
          # The tag with a label
          optgroup label: 'Optgroup'
          # Optgroup tag without label but sub-components
          optgroup do
            option text: 'Option A'
            option text: 'Option B'
            option text: 'Option C'
          end
          # Simple optgroup
          optgroup label: 'Simple Group' do
            option text: 'Option D'
            option text: 'Option E'
            option text: 'Option F'
          end
          # Enhanced optgroups
          optgroup label: 'Enabled Group 1', class: 'enabled' do
            option text: 'Option G'
            option text: 'Option H'
            option text: 'Option I'
          end
          optgroup label: 'Disabled Group 2', disabled: true, id: 'disabled' do
            option text: 'Option J'
            option text: 'Option K'
            option text: 'Option L'
          end
          optgroup label: 'Not Disabled Group 3', disabled: false, class: 'group', id: 'not-disabled' do
            option text: 'Option M'
            option text: 'Option N'
            option text: 'Option O'
          end
      end
    end

    visit '/example'
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
      <optgroup disabled="disabled" id="disabled" label="Disabled Group 2">
        <option>Option J</option>
        <option>Option K</option>
        <option>Option L</option>
      </optgroup>
      <optgroup id="not-disabled" label="Not Disabled Group 3" class="group">
        <option>Option M</option>
        <option>Option N</option>
        <option>Option O</option>
      </optgroup>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
