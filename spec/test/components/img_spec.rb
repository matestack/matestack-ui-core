require_relative '../support/utils'
include Utils

describe 'Img Component', type: :feature, js: true do

  it 'Renders an image tag on the page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple image
        img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
        # using usemap
        img path: 'matestack-logo.png', width: 500, height: 300, alt: "otherlogo",  usemap: "#newmap"
      end
    end

    visit '/example'
    static_output = page.html
    expected_html_output = <<~HTML
      <img alt="logo" height="300" src="#{ActionController::Base.helpers.asset_path('matestack-logo.png')}" width="500" />
      <img alt="otherlogo" height="300" src="#{ActionController::Base.helpers.asset_path('matestack-logo.png')}" usemap="#newmap" width="500" />
    HTML
    expect(stripped(static_output)).to include(stripped(expected_html_output))
  end
end
