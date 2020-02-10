require_relative '../../support/utils'
include Utils

describe 'Br Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

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

          # br tag with id and class
          plain 'hello'
          br id: 'my-br', class: 'fancy-br-class'
          plain 'world!'
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
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

    hello
    <br id="my-br" class="fancy-br-class"/>
    world!
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  end

end
