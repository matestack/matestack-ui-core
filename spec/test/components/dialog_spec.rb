require_relative '../support/utils'
include Utils

describe 'Dialog component', type: :feature, js: true do
  it 'Renders a simple and enhanced dialog tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # Simple dialog
        dialog text: 'Simple dialog tag'
        # Enhanced dialog
        dialog id: 'my-id', class: 'my-class', open: true do
          plain 'Enhanced dialog tag'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <dialog>Simple dialog tag</dialog>
      <dialog id="my-id" open="open" class="my-class">Enhanced dialog tag</dialog>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
