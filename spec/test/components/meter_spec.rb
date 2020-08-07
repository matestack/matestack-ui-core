require_relative '../support/utils'
include Utils

describe 'Meter Component', type: :feature, js: true do

  it 'Renders an meter tag on the page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        #label for: 'meter_id'
        meter id: 'meter_id', value: 0.6
        #label for: 'meter'
        meter id: 'meter', min: 0, max: 10, value: 6 do
          plain '6 out of 10. 60%.'
        end
        meter id: 'meter', low: 2, high: 8, optimum: 6, min: 0, max: 10, value: 6 do
          plain '6 out of 10. 60%.'
        end
      end
    end

    visit '/example'
    output_html = page.html
    expected_output = <<~HTML 
      <meter id="meter_id" value="0.6"></meter>
      <meter id="meter" max="10" min="0" value="6">6 out of 10. 60%.</meter>
      <meter high="8" id="meter" low="2" max="10" min="0" optimum="6" value="6">
        6 out of 10. 60%.
      </meter>
    HTML
    expect(stripped(output_html)).to include(stripped(expected_output))
  end
end
