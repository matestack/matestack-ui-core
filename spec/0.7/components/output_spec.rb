require_relative '../../support/utils'
include Utils

describe 'Output component', type: :feature, js: true do
  it 'Renders a simple and enhanced output tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          # Without content
          output name: 'x', for: 'a b'

          # Only content
          output text: 'Only content'

          # All attributes
          output id: 'my-id', class: 'my-class', name: 'x', for: 'a b', form: 'form_id' do
            plain 'All attributes'
          end
        }
      end
    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
      <output for="a b" name="x"></output>
      <output>Only content</output>
      <output for="a b" form="form_id" id="my-id" name="x" class="my-class">All attributes</output>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
