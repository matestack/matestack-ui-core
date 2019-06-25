require_relative "../../support/utils"
include Utils

describe 'Span Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple span
          span do
            plain 'I am simple'
          end

          # enhanced span
          span id: 'my-id', class: 'my-class' do
            plain 'I am enhanced'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <span>I am simple</span>
    <span id="my-id" class="my-class">I am enhanced</span>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
