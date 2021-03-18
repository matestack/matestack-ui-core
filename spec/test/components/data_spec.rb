require_relative '../support/utils'
include Utils

describe 'Data component', type: :feature, js: true do
  it 'Renders a simple and enhanced data tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # Simple data
        data id: 'foo', class: 'bar', value: '1301', text: 'Data example 1'
        # Enhanced data
        data id: 'foo', class: 'bar', value: '1300' do
          plain 'Data example 2' # optional content
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <data id="foo" value="1301" class="bar">
        Data example 1
      </data>
      <data id="foo" value="1300" class="bar">
        Data example 2
      </data>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
