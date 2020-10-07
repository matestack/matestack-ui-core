require 'rails_helper'

describe 'Map Component', type: :feature, js: true do
  include Utils

  it 'renders a map' do
    matestack_render do
      map name: 'newmap' do
        area shape: 'rect', coords: [0,0,100,100], href: 'first.htm', alt: 'First'
      end
    end
    expect(page).to have_selector("map[name='newmap']", visible: false)
    expect(page).to have_selector("map[name='newmap'] > area", visible: false)
  end
end
