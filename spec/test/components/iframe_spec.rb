require_relative "../support/utils"
include Utils

describe 'Iframe Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple iframe tag
        iframe src: "https://www.demopage.com" do
          plain 'The browser does not support iframe.'
        end
        # enhanced iframe tag
        iframe id: 'my-id', class: 'my-class', src: "https://www.demopage.com", srcdoc: "Mate Stack UI!" do
          plain 'The browser does not support iframe.'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <iframe src="https://www.demopage.com">The browser does not support iframe.</iframe>
      <iframe id="my-id" src="https://www.demopage.com" srcdoc="Mate Stack UI!" class="my-class">The browser does not support iframe.</iframe>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple iframe tag
        iframe 'The browser does not support iframe.', src: "https://www.demopage.com"
        # enhanced iframe tag
        iframe 'The browser does not support iframe.', id: 'my-id', class: 'my-class', src: "https://www.demopage.com",
          srcdoc: "Mate Stack UI!"
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <iframe src="https://www.demopage.com">The browser does not support iframe.</iframe>
      <iframe id="my-id" src="https://www.demopage.com" srcdoc="Mate Stack UI!" class="my-class">The browser does not support iframe.</iframe>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
