require_relative '../../support/utils'
include Utils

describe 'Ruby Component', type: :feature, js: true do

  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple ruby
        ruby text: 'I am simple'
        # enhanced ruby
        ruby id: 'my-id', class: 'my-class' do
          plain 'I am enhanced'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <ruby>I am simple</ruby>
      <ruby id="my-id" class="my-class">I am enhanced</ruby>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
