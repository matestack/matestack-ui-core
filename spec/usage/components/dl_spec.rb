require_relative "../../support/utils"
include Utils

describe 'Dl Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          dl id: 'my-id', class: 'my-class' do
            dt text: "dt component"
            dd text: "dd component"
          end
        }
      end

    end

    visit '/example'
    static_output = page.html

    expected_static_output = <<~HTML
    <dl id="my-id" class="my-class"><dt>dt component</dt><dd>dd component</dd></dl>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple dl tag
          dl text: 'This is simple dl text'

          # enhanced dl tag
          dl id: 'my-id', class: 'my-class', text: 'This is a enhanced dl with text'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <dl>This is simple dl text</dl>
    <dl id="my-id" class="my-class">This is a enhanced dl with text</dl>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end