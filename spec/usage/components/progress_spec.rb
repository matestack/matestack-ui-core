require_relative '../../support/utils'
include Utils

describe 'Progress Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          # simple progress bar
          progress value: 75, max: 100
          # enhanced progress bar
          progress id: 'my-id', class: 'my-class', value: 33, max: 330
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <progress max="100" value="75"></progress>
    <progress id="my-id" max="330" value="33" class="my-class"></progress>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
