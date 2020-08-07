require_relative '../support/utils'
include Utils

describe 'RP Component', type: :feature, js: true do

  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple rp
        rp text: 'I am simple'
        # enhanced rp
        rp id: 'my-id', class: 'my-class' do
          plain 'I am enhanced'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <rp>I am simple</rp>
      <rp id="my-id" class="my-class">I am enhanced</rp>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
