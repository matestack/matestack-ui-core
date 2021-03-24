require 'rails_helper'

describe "Address Component", type: :feature, js: true do
  include Utils

  it "Example 1 - yield a given block" do
    matestack_render do
      area shape: :rect, coords: [1,2,3,4].join(','), href: '#', hreflang: 'de', 
        media: "screen", rel: 'nofollow', target: :_blank
    end    
    expect(page).to have_selector(
      "area[shape='rect'][coords='1,2,3,4'][href='#'][hreflang='de'][media='screen'][rel='nofollow'][target='_blank']", 
      visible: false
    )
  end
end
