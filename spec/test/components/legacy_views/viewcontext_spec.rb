require_relative "../../support/utils"
include Utils

describe "Viewcontext", type: :feature, js: true do

  it 'should be accessible on components used on rails legacy views with matestack_component helper' do
    visit 'legacy_views/viewcontext_custom_component'
    expect(page).to have_content("has access to ActionView Context")
    expect(page).to have_content("Test Link")
    expect(page).to have_content("3 minutes")
    expect(page).to have_content("root_path: /")
  end

end
