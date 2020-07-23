require_relative "../../support/utils"
include Utils

describe 'Small Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple small tag
        small do
          plain 'I am a simple small tag'
        end
        # enhanced small tag
        small id: 'my-id', class: 'my-class' do
          plain 'I am a enhanced small tag'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <small>I am a simple small tag</small>
      <small id="my-id" class="my-class">I am a enhanced small tag</small>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple small
        small text: 'I am a simple small tag'
        # enhanced small
        small id: 'my-id', class: 'my-class', text: 'I am enhanced small tag'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <small>I am a simple small tag</small>
      <small id="my-id" class="my-class">I am enhanced small tag</small>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
