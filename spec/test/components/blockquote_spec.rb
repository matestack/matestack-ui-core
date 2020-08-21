require_relative "../support/utils"
include Utils

describe 'Blockquote Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple blockquote
        blockquote do
          plain 'This is simple blockquote text'
        end
        # enhanced blockquote
        blockquote id: 'my-id', class: 'my-class', cite: 'this is a cite' do
          plain 'This is a enhanced blockquote with text'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <blockquote>This is simple blockquote text</blockquote>
      <blockquote cite="this is a cite" id="my-id" class="my-class">This is a enhanced blockquote with text</blockquote>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple blockquote
        blockquote text: 'This is simple blockquote text'
        # enhanced blockquote
        blockquote id: 'my-id', class: 'my-class', cite: 'this is a cite', text: 'This is a enhanced blockquote with text'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <blockquote>This is simple blockquote text</blockquote>
      <blockquote cite="this is a cite" id="my-id" class="my-class">This is a enhanced blockquote with text</blockquote>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
