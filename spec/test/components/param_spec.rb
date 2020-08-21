require_relative '../support/utils'
include Utils

describe 'Param component', type: :feature, js: true do

  it 'Renders a param tag on a page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # Just the tag
        param
        # With some attributes
        param name: 'autoplay', value: 'true'
        # All attributes
        param name: 'autoplay', value: 'true', id: 'my-id', class: 'my-class'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <param/>
      <param name="autoplay" value="true"/>
      <param id="my-id" name="autoplay" value="true" class="my-class"/>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
