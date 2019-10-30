require_relative '../../support/utils'
include Utils

describe '<%= file_name.camelcase %> component', type: :feature, js: true do
  it 'Renders a simple and enhanced <%= file_name.underscore %> tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          # Simple <%= file_name.underscore %>
          <%= file_name.underscore %> text: 'Simple <%= file_name.underscore %> tag'

          # Enhanced <%= file_name.underscore %>
          <%= file_name.underscore %> id: 'my-id', class: 'my-class' do
            plain 'Enhanced <%= file_name.underscore %> tag'
          end
        }
      end
    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
      <<%= file_name.underscore %>>Simple <%= file_name.underscore %> tag</<%= file_name.underscore %>>
      <<%= file_name.underscore %> id="my-id" class="my-class">Enhanced <%= file_name.underscore %> tag</<%= file_name.underscore %>>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
