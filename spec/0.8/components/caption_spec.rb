require_relative '../../support/utils'
include Utils

describe 'Caption Component', type: :feature, js: true do

  it 'Example 1 - using the text option' do

    class ExamplePage < Matestack::Ui::Page
      def response
        table do
          caption text: "table caption 1"
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <caption>table caption 1</caption>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - using a block' do

    class ExamplePage < Matestack::Ui::Page
      def response
      
        table do
          caption do
            plain "table caption 2"
          end
        end
      
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <caption>table caption 2</caption>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
