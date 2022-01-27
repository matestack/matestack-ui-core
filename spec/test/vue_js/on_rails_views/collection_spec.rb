require 'rails_vue_js_spec_helper'
include VueJsSpecUtils

describe "Collection Component", type: :feature, js: true do

  it 'should work on rails legacy views' do
    visit 'legacy_views/collection_custom_component'
    expect(page).to have_content('Collection Custom Component')
    DummyModel.all.pluck(:title) do |title|
      expect(page).to have_content(title)
    end

    fill_in 'title-filter', with: 'Test'
    click_button 'filter'
    DummyModel.all.where('title LIKE ?', "%TEST%").pluck(:title).each do |title|
      expect(page).to have_content(title)
    end
    DummyModel.all.where.not('title LIKE ?', "%TEST%").pluck(:title).each do |title|
      expect(page).not_to have_content(title)
    end
  end

end
