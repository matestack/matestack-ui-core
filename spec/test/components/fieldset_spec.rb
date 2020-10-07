require 'rails_helper'

describe 'Fieldset Component', type: :feature, js: true do 
  include Utils

  it 'renders default fieldset with block' do
    matestack_render do
      fieldset do
        legend text: 'legend'
      end
    end
    expect(page).to have_selector('fieldset')
    expect(page).to have_selector('fieldset > legend', text: 'legend')
  end

  it 'can be disabled' do
    matestack_render do
      fieldset disabled: true
    end
    expect(page).to have_selector('fieldset[disabled="disabled"]')
  end

end