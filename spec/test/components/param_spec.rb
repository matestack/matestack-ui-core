require 'rails_helper'

describe 'Param component', type: :feature, js: true do
  include Utils

  it 'renders a param' do
    matestack_render do
      param
      param name: 'autoplay', value: 'true'
    end
    expect(page).to have_selector('param', count: 2, visible: false)
    expect(page).to have_selector("param[name='autoplay'][value='true']", visible: false)
  end
end
