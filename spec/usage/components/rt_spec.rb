require_relative '../../support/utils'
include Utils

describe 'RT Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # simple rt
          rt text: 'I am simple'

          # enhanced rt
          rt id: 'my-id', class: 'my-class' do
            plain 'I am enhanced'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
      <rt>I am simple</rt>
      <rt id="my-id" class="my-class">I am enhanced</rt>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
