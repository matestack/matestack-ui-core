require_relative '../../support/utils'
include Utils

describe 'Icon Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          # using the icon tag as italic styling
          icon text: 'I am italic text'

          # Fontawesome icon tag without options[:text]
          icon class: 'fab fa-500px'

          # MDL icon without options[:text]
          icon class: 'material-icons' do
            plain 'accessibility'
          end

          # MDL icon with options[:text] (recommended)
          icon class: 'material-icons', text: 'check_circle'
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <i>I am italic text</i>
    <i class="fab fa-500px"></i>
    <i class="material-icons">
      accessibility
    </i>
    <i class="material-icons">
      check_circle
    </i>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
