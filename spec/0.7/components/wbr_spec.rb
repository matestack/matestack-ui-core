require_relative '../../support/utils'
include Utils

describe 'Wbr component', type: :feature, js: true do
  it 'Renders a simple and enhanced wbr tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          # Simple wbr
          paragraph do
            plain 'First part of text'
            wbr
            plain 'Second part of text'
          end

          # Enhanced wbr
          paragraph do
            plain 'First part of second text'
            wbr id: 'special', class: 'nice-wbr'
            plain 'Second part of second text'
          end
        }
      end
    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
      <p>First part of text<wbr/>Second part of text</p>
      <p>First part of second text<wbr id="special" class="nice-wbr"/>Second part of second text</p>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
