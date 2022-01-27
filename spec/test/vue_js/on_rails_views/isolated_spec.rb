require 'rails_vue_js_spec_helper'
include VueJsSpecUtils

describe "Isolated Component", type: :feature, js: true do

  it 'should work on rails legacy views' do
    visit 'legacy_views/isolated_custom_component'

    expect(page).to have_content('Isolated Custom Component')
    expect(page).to have_css('.my-isolated')
    expect(page).to have_css('#async-time')
    initial_timestamp = page.find(".my-isolated").text #initial page load
    
    page.execute_script('MatestackUiVueJs.eventHub.$emit("update_time")')
    expect(page).to have_content('Isolated Custom Component')
    expect(page).to have_css('.my-isolated')
    expect(page).to have_css('#async-time')
    expect(page).not_to have_content(initial_timestamp)
    async_timestamp = page.find("#async-time").text #initial page load
    
    expect(page).to have_content(async_timestamp, count: 2)
    # rerender async inside isolate
    page.execute_script('MatestackUiVueJs.eventHub.$emit("async_update_time")')
    expect(page).to have_css('.my-isolated')
    expect(page).to have_css('#async-time')
    expect(page).to have_content(async_timestamp, count: 1) # isolate component still has same timestamp, async has different
  end

end
