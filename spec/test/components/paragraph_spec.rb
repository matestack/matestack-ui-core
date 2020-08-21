require_relative '../support/utils'
include Utils

describe 'Paragraph Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple paragraph
        paragraph text: 'I am simple'
        # enhanced paragraph
        paragraph id: 'my-id', class: 'my-class' do
          plain 'I am enhanced'
        end
        # alias pg
        pg text: 'Alias paragraph'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <p>I am simple</p>
      <p id="my-id" class="my-class">I am enhanced</p>
      <p>Alias paragraph</p>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
