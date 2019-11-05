require_relative '../../support/utils'
include Utils

describe 'Map Component', type: :feature, js: true do

  it 'Renders an image and a map containing areas on the page' do

    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          img path: 'matestack-logo.png', width: 500, height: 300, alt: "otherlogo",  usemap: "#newmap"

          map name: 'newmap' do
            area shape: 'rect', coords: [0,0,100,100], href: 'first.htm', alt: 'First'
            area shape: 'rect', coords: [0,0,100,100], href: 'second.htm', alt: 'Second'
            area shape: 'rect', coords: [0,0,100,100], href: 'third.htm', alt: 'Third'
          end
        }
      end
    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <img src="matestack-logo.png" alt="otherlogo" width="500" height="300" usemap="#newmap">

    <map name="newmap">
       <area shape="rect" coords="0,0,100,100" href="first.htm" alt="First">
       <area shape="rect" coords="100,100,200,200" href="second.htm" alt="Second">
       <area shape="rect" coords="200,200,300,300" href="third.htm" alt="Third">
    </map>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
