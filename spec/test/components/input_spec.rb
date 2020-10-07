require 'rails_helper'

describe 'Input Component', type: :feature, js: true do
  include Utils

  it 'renders a input' do
    matestack_render do
      input
    end
    expect(page).to have_selector('input')
  end

  it 'is possible to render different input types' do
    matestack_render do
      input type: :email
      input type: :range, min: 0, max: 10, step: 0.5
    end
    expect(page).to have_selector("input[type='email']")
    expect(page).to have_selector("input[type='range'][min='0'][max='10'][step='0.5']")
  end

end
