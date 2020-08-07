require_relative '../support/utils'
include Utils

describe 'Input Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple input tag
        input
        # email input tag
        input type: :email
        # range input with max, min, step
        input type: :range, attributes: { min: 0, max: 10, step: 0.5 }
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
    <input />
    <input type="email" />
    <input max="10" min="0" step="0.5" type="range" />
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
