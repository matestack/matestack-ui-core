require_relative '../../support/utils'
include Utils

describe 'Bdi component', type: :feature, js: true do
  it 'Renders a simple and enhanced bdi tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
          # Simple bdi
          bdi text: 'Simple bdi tag'
          # Enhanced bdi
          bdi id: 'my-id', class: 'my-class' do
            plain 'Enhanced bdi tag'
          end
      end
    end

    visit '/example'

    static_output = page.html
    expected_static_output = <<~HTML
      <bdi>Simple bdi tag</bdi>
      <bdi id="my-id" class="my-class">Enhanced bdi tag</bdi>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
