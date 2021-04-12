require 'rails_helper'

describe 'Video Component', type: :feature, js: true do
  include Utils

  it 'Renders a simple video tag on the page' do
    matestack_render do
      video width: 500, height: 300 do
        source src: 'corgi.mp4', type: "video/mp4"
      end
    end
    expect(page).to have_selector("video[height='300'][width='500']")
    expect(page).to have_selector(
      "video > source[src='corgi.mp4'][type='video/mp4']",
      visible: false
    )
  end
  
  it 'Renders a video tag with more attributes on the page' do
    matestack_render do
      video width: 500, height: 300,  autoplay: true, controls: true, loop: true, muted: true, playsinline: false, preload: 'auto'
    end
    expect(page).to have_selector("video[controls='controls'][loop='loop'][muted='muted'][preload='auto']")
  end
end
