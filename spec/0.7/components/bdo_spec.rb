require_relative '../../support/utils'
include Utils

describe 'Bdo component', type: :feature, js: true do
  it 'Renders a simple and enhanced bdo tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          # Simple bdo
          bdo dir: 'ltr', text: 'Simple bdo ltr tag'
          bdo dir: 'rtl', text: 'Simple bdo rtl tag'

          # Enhanced bdo
          bdo id: 'foo', class: 'bar', dir: 'ltr' do
            plain 'This text will go left-to-right.' # optional content
          end
          bdo id: 'bar', class: 'foo', dir: 'rtl' do
            plain 'This text will go right-to-left.' # optional content
          end
        }
      end
    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
      <bdo dir="ltr">Simple bdo ltr tag</bdo>
      <bdo dir="rtl">Simple bdo rtl tag</bdo>
      <bdo dir="ltr" id="foo" class="bar">This text will go left-to-right.</bdo>
      <bdo dir="rtl" id="bar" class="foo">This text will go right-to-left.</bdo>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))

  end

  it 'Fails if required dir tag is not set' do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          bdo text: 'Simple bdo ltr tag'
        }
      end
    end

    visit '/example'

    expect(page).to have_content("required key 'dir' is missing")

  end
end
