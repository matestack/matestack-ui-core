require 'rails_helper'

describe 'Meter Component', type: :feature, js: true do
  include Utils

  it 'Renders an meter tag on the page' do
    matestack_render do
      #label for: 'meter_id'
      meter id: 'meter_id', value: 0.6
      #label for: 'meter'
      meter '6 out of 10. 60%.', id: 'meter', min: 0, max: 10, value: 6
      meter id: 'meter', low: 2, high: 8, optimum: 6, min: 0, max: 10, value: 6 do
        plain '6 out of 10. 60%.'
      end
    end
    expect(page).to have_selector("meter#meter_id[value='0.6']")
    expect(page).to have_selector("meter#meter[value='6'][min='0'][max='10']", text: '6 out of 10. 60%.')
    expect(page).to have_selector("meter#meter[value='6'][min='0'][max='10'][optimum='6'][high='8'][low='2']", text: '6 out of 10. 60%.')
  end
end
