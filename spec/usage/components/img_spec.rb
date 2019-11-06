require_relative '../../support/utils'
include Utils

describe 'Img Component', type: :feature, js: true do

  it 'Renders an image tag on the page' do

    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          # simple image
          img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
          # using usemap
          img path: 'matestack-logo.png', width: 500, height: 300, alt: "otherlogo",  usemap: "#newmap"
        }
      end
    end

    visit '/example'

    expect(page).to have_xpath("//img[contains(@src,'matestack-logo') and @alt='logo' and @width='500' and @height='300']")
    expect(page).to have_xpath("//img[contains(@src,'matestack-logo') and @alt='otherlogo' and @width='500' and @height='300' and @usemap='\#newmap']")
  end
end
