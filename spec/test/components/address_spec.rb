require 'rails_helper'

describe "Address Component", type: :feature, js: true do
  include Utils

  it "Example 1 - yield a given block" do
    matestack_render do
      address do
        plain "Codey McCodeface"
        br
        plain "1 Developer Avenue"
        br
        plain "Techville"
      end
    end
    expect(page).to have_selector('address br', count: 2, visible: false)
    expect(page).to have_selector('address', text: "Codey McCodeface\n1 Developer Avenue\nTechville")
  end
  
  it "Example 2 - render options[:text] param" do
    matestack_render do
      address "PO Box 12345"
    end
    expect(page).to have_selector('address', text: "PO Box 12345")
  end
end
