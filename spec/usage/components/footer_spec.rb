require_relative '../../support/utils'
include Utils

describe 'Footer Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          # simple footer tag
          footer do
            plain 'hello world!'
          end

          # advanced footer tag
          footer id: 'my-unique-footer', class: 'awesome-footer' do
            paragraph class: 'footer-text', text: 'hello world!'
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <footer>hello world!</footer>
    <footer id="my-unique-footer" class="awesome-footer">
      <p class="footer-text">hello world!</p>
    </footer>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
