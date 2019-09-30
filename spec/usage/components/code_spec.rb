require_relative '../../support/utils'
include Utils

describe 'Paragraph Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # example 1
          code id: "foo", class: "bar" do
            plain 'puts "Hello Mate One"'
          end
          # example 2
          code id: "foo", class: "bar", text: 'puts "Hello Mate Two"'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <code id="foo" class="bar">puts "Hello Mate One"</code>
    <code id="foo" class="bar">puts "Hello Mate Two"</code>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
