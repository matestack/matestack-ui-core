require_relative '../../support/utils'
include Utils

describe 'Button Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple button
        button text: 'Click me, m8'
        # enhanced button
        button id: "my-button-id-1", class: "my-button-class", text: "Click me, m8"
        # button with block inside
        button do
          plain 'Click me too, m8'
        end
        # button with text and block - does render text and neglect block
        button text: 'I am prefered' do
          plain 'I will not get shown'
        end
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
    <button>Click me, m8</button>
    <button id="my-button-id-1" class="my-button-class">
      Click me, m8
    </button>
    <button>Click me too, m8</button>
    <button>I am prefered</button>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2: disabled buttons' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # three possible ways of (not) using disabled buttons
        button disabled: true, text: 'You can not click me'
        button disabled: false, text: 'You can click me'
        button text: 'You can click me too'
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
    <button disabled="disabled">You can not click me</button>
    <button>You can click me</button>
    <button>You can click me too</button>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
