require_relative '../../support/utils'
include Utils

describe 'Pre Component', type: :feature, js: true do

  it 'Example 1 - yield a given block' do
    class ExamplePage < Matestack::Ui::Page
      def response
        pre do
          plain 'This is preformatted text'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <pre>This is preformatted text</pre>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text] param' do
    class ExamplePage < Matestack::Ui::Page
      def response
        pre text: 'This is preformatted text'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <pre>This is preformatted text</pre>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
