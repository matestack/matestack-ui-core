require_relative '../support/utils'
include Utils

describe 'mark Component', type: :feature, js: true do

  it 'Renders a simple and enhanced mark tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple mark
        mark text: 'Simple mark Tag'
        # enhanced mark
        mark id: 'my-id', class: 'my-class' do
          plain 'Enhanced mark Tag'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <mark>Simple mark Tag</mark>
      <mark id="my-id" class="my-class">Enhanced mark Tag</mark>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
  
end
