require_relative '../../support/utils'
include Utils

describe 'Picture component', type: :feature, js: true do
  it 'Renders a picture tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          # Just the tag
          picture

          # With attributes
          picture id: 'my-id', class: 'my-class'

          # With a sub-component
          picture do
            img path: 'matestack-logo.png'
          end
        }
      end
    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
      <picture></picture>
      <picture id="my-id" class="my-class"></picture>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
    expect(page).to have_xpath("//img[contains(@src,'matestack-logo')]")
  end
end
