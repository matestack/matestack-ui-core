require 'rails_vue_js_spec_helper'
include VueJsSpecUtils

describe "Action Component", type: :feature, js: true do

  it 'should work on rails legacy views' do
    visit 'legacy_views/action_custom_component'
    expect(page).to have_content('Action Custom Component')
    expect(page).not_to have_content('Action was successful')
    expect(page).not_to have_content('Action has failed')

    click_button 'See Success'
    expect(page).to have_content('Action was successful')

    click_button 'See Failure'
    expect(page).to have_content('Action has failed')

    click_button 'Redirect to inline action'
    expect(page).to have_content('Inline Action Component')
    expect(page).not_to have_content('Action was successful')
    expect(page).not_to have_content('Action has failed')

    click_button 'See Success'
    expect(page).to have_content('Action was successful')

    click_button 'See Failure'
    expect(page).to have_content('Action has failed')
  end

end
