require 'rails_helper'

describe 'Wbr component', type: :feature, js: true do
  include Utils

  it 'renders a wbr' do
    matestack_render do
      paragraph do
        plain 'foo'
        wbr
        plain 'bar'
        wbr id: 'id', class: 'class'
      end
    end
    expect(page).to have_selector('p > wbr', visible: false, count: 2)
    expect(page).to have_selector('p > wbr + wbr#id.class', visible: false)
  end

end
