require_relative '../../support/utils'
include Utils

describe 'Abbr Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          abbr title: 'Hypertext Markup Language', text: 'HTML'
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <abbr title="Hypertext Markup Language">HTML</abbr>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          abbr title: 'Cascading Style Sheets' do
            span do
              plain 'CSS'
            end
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <abbr title="Cascading Style Sheets"><span>CSS</span></abbr>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
