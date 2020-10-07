require 'rails_helper'

describe 'Br Component', type: :feature, js: true do
  include Utils

  it 'Example 1' do
    matestack_render do
      br
      br
    end
    expect(page).to have_selector('br', count: 2, visible: false)
  end

end
