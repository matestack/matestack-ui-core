require_relative '../../support/utils'
include Utils

describe 'Figure Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page
      def response
        figure id: "my-id", class: "my-class" do
          img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_html_output = <<~HTML
      <figure id="my-id" class="my-class">
        <img alt="logo" height="300" src="#{ActionController::Base.helpers.asset_path('matestack-logo.png')}" width="500" />
      </figure>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_html_output))
  end
end
