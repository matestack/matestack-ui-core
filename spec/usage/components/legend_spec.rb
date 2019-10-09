require_relative '../../support/utils'
include Utils

describe 'Legend Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          legend text: 'I am simple'

          # enhanced legend
          legend id: 'my-id', class: 'my-class' do
            plain 'I am enhanced'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
      <legend>I am simple</legend>
      <legend id="my-id" class="my-class">I am enhanced</legend>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
