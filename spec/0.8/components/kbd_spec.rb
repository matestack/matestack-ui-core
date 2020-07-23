require_relative '../../support/utils'
include Utils

describe 'kbd Component', type: :feature, js: true do
  it 'Renders a simple and enhanced kbd tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple kbd
        kbd text: 'Simple Keyboard Input'
        # enhanced kbd
        kbd id: 'my-id', class: 'my-class' do
          plain 'Enhanced Keyboard Input'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <kbd>Simple Keyboard Input</kbd>
      <kbd id="my-id" class="my-class">Enhanced Keyboard Input</kbd>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
