require_relative "../../support/utils"
include Utils

describe 'u Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple u
          u do
            plain 'I am simple'
          end

          # enhanced u
          u id: 'my-id', class: 'my-class' do
            plain 'I am enhanced'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <u>I am simple</u>
    <u id="my-id" class="my-class">I am enhanced</u>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple u
          u text: 'I am simple'

          # enhanced u
          u id: 'my-id', class: 'my-class', text: 'I am enhanced'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <u>I am simple</u>
    <u id="my-id" class="my-class">I am enhanced</u>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
