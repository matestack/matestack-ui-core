require 'rails_helper'

describe 'Horizontal Rule Component', type: :feature, js: true do
  include Utils

  it 'renders a hr' do
    matestack_render do
      hr id: 'id', class: 'class'
    end

    expect(page).to have_selector('hr#id.class')
  end

end
