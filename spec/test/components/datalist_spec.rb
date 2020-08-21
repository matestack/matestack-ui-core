require_relative "../support/utils"
include Utils

describe 'Datalist Component', type: :feature, js: true do

  it 'Example 1 - yield' do

    class ExamplePage < Matestack::Ui::Page
      def response
        datalist id: 'foo', class: 'bar' do
          plain 'Example Text'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <datalist id="foo" class="bar">Example Text</datalist>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
