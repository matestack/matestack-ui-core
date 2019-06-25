require_relative '../../support/utils'
include Utils

describe 'Absolute Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          absolute top: 50, left: 50, right: 50, bottom: 100, z: 3 do
            plain 'I am absolute content'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <div style="position: absolute; top: 50px; left: 50px; right: 50px; bottom: 100px; z-index: 3;">I am absolute content</div>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
