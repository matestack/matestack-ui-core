require_relative '../../support/utils'
include Utils

describe 'Paragraph Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple paragraph
          pg text: 'I am simple'

          # enhanced paragraph
          pg id: 'my-id', class: 'my-class' do
            plain 'I am enhanced'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <p>I am simple</p>
    <p id="my-id" class="my-class">I am enhanced</p>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
