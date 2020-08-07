require_relative '../support/utils'
include Utils

describe 'Object Component', type: :feature, js: true do

  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple object
        object width: 400, height: 400, data: 'helloworld.swf'
        # enhanced object
        object id: 'my-id', class: 'my-class', width: 400, height: 400, data: 'helloworld.swf'
        # using all attributes
        object id: 'my-id', class: 'my-class', width: 400, height: 400, form: '#my_form', data: 'helloworld.swf', 
          name: 'my_object', type: 'application/vnd.adobe.flash-movie', usemap: '#my_map'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
    <object data="helloworld.swf" height="400" width="400"></object>
    <object data="helloworld.swf" height="400" id="my-id" width="400" class="my-class"></object>
    <object data="helloworld.swf" form="#my_form" height="400" id="my-id" name="my_object" type="application/vnd.adobe.flash-movie" usemap="#my_map" width="400" class="my-class"></object>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
