require_relative "../../support/utils"
include Utils

describe 'Article Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        article do
          paragraph text: "Hello world"
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <article><p>Hello world</p></article>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        article text: "Hello world"
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <article>Hello world</article>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
