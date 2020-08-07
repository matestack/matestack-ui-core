require_relative '../support/utils'
include Utils

describe 'Horizontal Rule Component', type: :feature, js: true do

  it 'Renders an hr tag on the page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple horizontal rule
        hr id: 'my-id', class: 'my-class'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <hr id="my-id" class="my-class"/>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
