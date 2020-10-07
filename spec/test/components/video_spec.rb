require 'rails_helper'

describe 'Video Component', type: :feature, js: true do
  include Utils

  it 'Renders a simple video tag on the page' do
    matestack_render do
      video path: 'corgi.mp4', type: "mp4", width: 500, height: 300
    end
    expect(page).to have_selector("video[height='300'][width='500']", text: 'Your browser does not support the video tag.')
    expect(page).to have_selector(
      "video > source[src='#{ActionController::Base.helpers.asset_path('corgi.mp4')}'][type='video/mp4']",
      visible: false
    )
  end
  
  it 'Renders a video tag with more attributes on the page' do
    matestack_render do
      video path: 'corgi.mp4', type: "mp4", width: 500, height: 300,  autoplay: true, controls: true, loop: true, muted: true, playsinline: false, preload: 'auto'
    end
    expect(page).to have_selector("video[controls='controls'][loop='loop'][muted='muted'][preload='auto']")
  end
end
