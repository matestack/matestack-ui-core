require 'rails_helper'

describe 'Img Component', type: :feature do
  include Utils

  it 'renders a img' do
    matestack_render do
      img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
      img path: 'matestack-logo.png', width: 500, height: 300, alt: "otherlogo",  usemap: "#newmap"
    end

    expect(page).to have_selector(
      "img[alt='logo'][height='300'][width='500'][src='#{ActionController::Base.helpers.asset_path('matestack-logo.png')}']"
    )
    expect(page).to have_selector(
      "img[alt='otherlogo'][height='300'][width='500'][usemap='#newmap'][src='#{ActionController::Base.helpers.asset_path('matestack-logo.png')}']"
    )
  end
end
