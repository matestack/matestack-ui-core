require_relative "../../../support/utils"
include Utils

describe "Form Component", type: :feature, js: true do

  it 'should work on rails legacy views' do
    new_title = SecureRandom.uuid
    visit 'legacy_views/form_custom_component'
    expect(page).to have_content('Form Custom Component')
    expect(page).not_to have_content(new_title)
    
    fill_in 'title', with: new_title
    click_button 'Save'
    expect(page).to have_content(new_title)
  end

end