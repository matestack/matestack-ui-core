require_relative '../../support/utils'
include Utils

describe 'Img Component', type: :feature, js: true do

  it 'Renders an image tag on the page' do

    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
        }
      end
    end

    visit '/example'

    expect(page).to have_xpath("//img[contains(@src,'matestack-logo') and @alt='logo' and @width='500' and @height='300']")
  end
end
