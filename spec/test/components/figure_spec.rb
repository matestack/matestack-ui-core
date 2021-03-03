require 'rails_helper'

describe 'Figure Component', type: :feature do
  include Utils

  it 'renders a figure' do
    matestack_render do
      figure class: 'class', id: 'id' do
        img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
      end
    end
    expect(page).to have_selector('figure#id.class')
    expect(page).to have_selector('figure#id.class > img')
  end
end
