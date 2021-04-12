require_relative "../../support/utils"
include Utils

describe "Onclick Component", type: :feature, js: true do

  it 'should work on rails legacy views' do
    visit 'legacy_views/onclick_custom_component'
    expect(page).to have_content('Onclick Custom Component')
    expect(page).not_to have_content('clicked')

    click_button 'Click me!'
    expect(page).to have_content('clicked')
  end

end
