require_relative '../../support/utils'
include Utils

describe 'Object Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple object
          object width: 400, height: 400, data: 'helloworld.swf'

          # enhanced object
          object id: 'my-id', class: 'my-class', width: 400, height: 400, data: 'helloworld.swf'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <object width="400" height="400" data="helloworld.swf"></object>
    <object id="my-id" class="my-class" width="400" height="400" data="helloworld.swf"></object>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
