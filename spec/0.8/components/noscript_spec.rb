require_relative '../../support/utils'
include Utils

describe 'Noscript Component', type: :feature, js: true do

  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple noscript
        noscript text: 'I am simple'
        # enhanced noscript
        noscript id: 'my-id', class: 'my-class' do
          plain 'I am enhanced'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <noscript>I am simple</noscript>
      <noscript id="my-id" class="my-class">I am enhanced</noscript>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
