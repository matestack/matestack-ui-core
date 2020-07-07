require_relative '../../support/utils'
include Utils

describe 'Samp component', type: :feature, js: true do
  it 'Renders a simple and enhanced samp tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # Simple samp
        samp text: 'Simple samp tag'
        # Enhanced samp
        samp id: 'my-id', class: 'my-class' do
          plain 'Enhanced samp tag'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <samp>Simple samp tag</samp>
      <samp id="my-id" class="my-class">Enhanced samp tag</samp>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
