require_relative '../../support/utils'
include Utils

describe 'Fieldset Component', type: :feature, js: true do 
  it 'fieldset with 1 input and legend' do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          fieldset do
            legend text: 'input legend'
            input
          end
          
          # advanced
          fieldset class: 'foo', id: 'world' do
            legend id: 'bar', class: 'hello', text: 'input legend'
            input
          end
          
          # with disabled 
          fieldset disabled: true do
            legend text: 'input legend'
            input
          end
        }
      end
    end

    visit '/example'

    static_output = page.html
    
    expected_html_output = <<~HTML
      <fieldset>
        <legend>input legend</legend>
        <input/>
      </fieldset>
      
      <fieldset id="world" class="foo">
      <legend id="bar" class="hello">input legend</legend>
      <input/>
      </fieldset>
      
      <fieldset disabled="disabled">
        <legend>input legend</legend>
        <input/>
      </fieldset>

    HTML
    expect(stripped(static_output)).to include(stripped(expected_html_output))
  end
end