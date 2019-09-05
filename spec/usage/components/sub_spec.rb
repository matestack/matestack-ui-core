require_relative "../../support/utils"
include Utils

describe 'Sub Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple sub
          sub do
            plain 'I am simple'
          end

          # enhanced sub
          sub id: 'my-id', class: 'my-class' do
            plain 'I am enhanced'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <sub>I am simple</sub>
    <sub id="my-id" class="my-class">I am enhanced</sub>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple sub
          sub text: 'I am simple'

          # enhanced sub
          sub id: 'my-id', class: 'my-class',text: 'I am enhanced'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <sub>I am simple</sub>
    <sub id="my-id" class="my-class">I am enhanced</sub>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
