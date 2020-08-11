require_relative "../../support/utils"
include Utils

describe "Isolated Component", type: :feature, js: true do

  it 'should work on rails legacy views' do
    visit 'legacy_views/isolated_custom_component'

    expect(page).to have_content('Isolated Custom Component')
    expect(page).to have_css('.my-isolated')
    initial_timestamp = page.find(".my-isolated").text #initial page load
    sleep
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("update_time")')
    expect(page).to have_content('Isolated Custom Component')
    expect(page).to have_css('.my-isolated')
    expect(page).not_to have_content(initial_timestamp)
  end

end
