require_relative '../../support/utils'
include Utils

describe 'Figure Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          figure id: "my-id", class: "my-class" do
            img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
          end
        }
      end
    end

    visit '/example'

    expect(page).to have_xpath("//figure[@id='my-id' and @class='my-class']/img[contains(@src,'matestack-logo') and @alt='logo' and @width='500' and @height='300']")
  end
end
