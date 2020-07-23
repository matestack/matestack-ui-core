require_relative "../../support/utils"
include Utils

describe 'Q Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple quote
          q do
            plain 'This is simple quote text'
          end

          # enhanced quote
          q id: 'my-id', class: 'my-class', cite: 'this is a cite' do
            plain 'This is a enhanced quote with text'
          end
        }
      end

    end

    visit '/example'
    static_output = page.html

    expected_static_output = <<~HTML
    <q>This is simple quote text</q>
    <q cite="this is a cite" id="my-id" class="my-class">This is a enhanced quote with text</q>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple quote
          q text: 'This is simple quote text'

          # enhanced quote
          q id: 'my-id', class: 'my-class', cite: 'this is a cite', text: 'This is a enhanced quote with text'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <q>This is simple quote text</q>
    <q cite="this is a cite" id="my-id" class="my-class">This is a enhanced quote with text</q>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
