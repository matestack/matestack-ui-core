require_relative '../support/utils'
include Utils

describe 'Option component', type: :feature, js: true do
  
  it 'Renders a option tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        option 'TEXT text'
        option label: 'TEXT label'
        option 'TEXT text', label: 'TEXT label'
        option id: 'my-id', class: 'my-class' do
          plain 'TEXT plain'
        end
        option disabled: true, label: 'TEXT label', selected: true, value: 'value'
        option disabled: false, label: 'TEXT label', selected: true, value: 'value'
        option disabled: true, label: 'TEXT label', selected: false, value: 'value'
        option disabled: false, label: 'TEXT label', selected: false, value: 'value'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <option>TEXT text</option>
      <option label="TEXT label"></option>
      <option label="TEXT label">TEXT text</option>
      <option id="my-id" class="my-class">TEXT plain</option>
      <option disabled="disabled" label="TEXT label" selected="selected" value="value"></option>
      <option label="TEXT label" selected="selected" value="value"></option>
      <option disabled="disabled" label="TEXT label" value="value"></option>
      <option label="TEXT label" value="value"></option>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
