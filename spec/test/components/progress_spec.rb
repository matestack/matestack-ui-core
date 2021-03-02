require_relative '../support/utils'
include Utils

describe 'Progress Component', type: :feature, js: true do

  it 'Example 1: Test positive behavior' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple progress bar
        progress value: 75, max: 100
        # enhanced progress bar
        progress id: 'my-id', class: 'my-class', value: 33, max: 330
        # expect value to default to zero
        progress max: 500
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <progress value="75" max="100"></progress>
      <progress id="my-id" class="my-class" value="33" max="330"></progress>
      <progress max="500"></progress>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
