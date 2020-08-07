require_relative "../support/utils"
include Utils

describe 'Dt Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple dt tag
        dt do
          plain 'This is simple dt text'
        end
        # enhanced dt tag
        dt id: 'my-id', class: 'my-class' do
          plain 'This is a enhanced dt with text'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <dt>This is simple dt text</dt>
      <dt id="my-id" class="my-class">This is a enhanced dt with text</dt>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple dt tag
        dt text: 'This is simple dt text'
        # enhanced dt tag
        dt id: 'my-id', class: 'my-class', text: 'This is a enhanced dt with text'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <dt>This is simple dt text</dt>
      <dt id="my-id" class="my-class">This is a enhanced dt with text</dt>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
