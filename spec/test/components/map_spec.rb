require_relative '../support/utils'
include Utils

describe 'Map Component', type: :feature, js: true do

  it 'Renders an image and a map containing areas on the page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        img path: 'matestack-logo.png', width: 500, height: 300, alt: "otherlogo",  usemap: "#newmap"
        map name: 'newmap' do
          area shape: 'rect', coords: [0,0,100,100], href: 'first.htm', alt: 'First'
          area shape: 'rect', coords: [100,100,200,200], href: 'second.htm', alt: 'Second'
          area shape: 'rect', coords: [200,200,300,300], href: 'third.htm', alt: 'Third'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <map name="newmap">
        <area alt="First" coords="0,0,100,100" href="first.htm" shape="rect"/>
        <area alt="Second" coords="100,100,200,200" href="second.htm" shape="rect"/>
        <area alt="Third" coords="200,200,300,300" href="third.htm" shape="rect"/>
      </map>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
    expect(page).to have_xpath("//img[contains(@src,'matestack-logo') and @alt='otherlogo' and @width='500' and @height='300' and @usemap='\#newmap']")
  end
end
