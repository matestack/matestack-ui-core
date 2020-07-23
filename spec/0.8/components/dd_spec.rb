require_relative "../../support/utils"
include Utils

describe 'Dd Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple dd tag
        dd do
          plain 'This is simple dd text'
        end
        # enhanced dd tag
        dd id: 'my-id', class: 'my-class' do
          plain 'This is a enhanced dd with text'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <dd>This is simple dd text</dd>
      <dd id="my-id" class="my-class">This is a enhanced dd with text</dd>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple dd tag
        dd text: 'This is simple dd text'
        # enhanced dd tag
        dd id: 'my-id', class: 'my-class', text: 'This is a enhanced dd with text'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <dd>This is simple dd text</dd>
      <dd id="my-id" class="my-class">This is a enhanced dd with text</dd>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
