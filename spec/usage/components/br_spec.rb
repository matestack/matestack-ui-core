require_relative '../../support/utils'
include Utils

describe 'Br Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          # simple br tag
          plain 'hello'
          br
          plain 'world!'

          # multiple br tags
          plain 'hello'
          br times: 5
          plain 'world!'
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output_1 = <<~HTML
    hello
    <br>
    world!

    hello
    <br>
    <br>
    <br>
    <br>
    <br>
    world!
    HTML

    expected_static_output_2 = <<~HTML
    hello
    <br/>
    world!

    hello
    <br/>
    <br/>
    <br/>
    <br/>
    <br/>
    world!
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output_1)) or include(stripped(expected_static_output_2)) )
  end

end
