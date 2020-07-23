require_relative "../../support/utils"
include Utils

describe 'Details Element with summary', type: :feature, js: true do
  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # basic
        details do
          summary text: 'Hello'
          paragraph text: 'World!'
        end
        # without summary
        details id: 'foo' do
          plain "Hello World!"
        end
        # enhanced
        details id: 'detail_id', class: 'detail_class' do
          summary id: 'summary_id', class: 'summary_class', text: 'Hello'
          paragraph text: 'World!'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <details>
        <summary>Hello</summary>
        <p>World!</p>
      </details>
      <details id="foo">
        Hello World!
      </details>
      <details id="detail_id" class="detail_class">
        <summary id="summary_id" class="summary_class">Hello</summary>
        <p>World!</p>
      </details>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
