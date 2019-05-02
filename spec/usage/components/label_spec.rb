require_relative '../../support/utils'
include Utils

describe 'Label Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          # simple label
          label text: 'I am simple'

          # enhanced label
          label id: 'my-id', class: 'my-class' do
            plain 'I am enhanced'
          end
        }
      end

    end

    visit '/example'

    static_output = page.html

    expected_static_output = <<~HTML
    <label>I am simple</label>
    <label id="my-id" class="my-class">I am enhanced</label>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
