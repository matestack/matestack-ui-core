require_relative '../../support/utils'
include Utils

describe 'Meter Component', type: :feature, js: true do

  it 'Renders an meter tag on the page' do

    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          label for: 'meter_id'
          meter id: 'meter_id', value: 0.6

          label for: 'meter'
          meter id: 'meter', min: 0, max: 10, value: 6 do
            plain '6 out of 10. 60%.'
          end
        }
      end
    end

    visit '/example'

    output_html = page.html

    expected_output = <<~HTML 
      <label for="meter_id"></label>
      <meter id="meter_id" value="0.6"></meter>

      <label for="meter"></label>
      <meter id="meter" min="0" max="10" value="6">
        6 out of 10. 60%.
      </meter>
    HTML
    binding.pry

    expect(stripped(output_html)).to include(stripped(expected_output))
  end
end
