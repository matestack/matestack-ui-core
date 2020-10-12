require 'rails_helper'

describe "Cable Component - append", type: :feature, js: true do
  include Utils

  it 'should have the typical matestack wrapping classes' do
    matestack_render do
      cable id: 'foobar' do
        plain 'cable'
      end
    end
    container = '.matestack-cable-component-container'
    wrapper = '.matestack-cable-component-wrapper'
    expect(page).to have_selector("#{container}")
    expect(page).to have_selector("#{container} > #{wrapper}")
    expect(page).to have_selector("#{container} > #{wrapper} > #foobar.matestack-cable-component-root", text: 'cable')
  end

  it 'should require an id' do
    matestack_render do
      cable
    end
    expect(page).to have_content('Required property id is missing for Matestack::Ui::Core::Cable::Cable')
  end

  it 'should work after a page transition' do
    pending
    fail
  end

end
