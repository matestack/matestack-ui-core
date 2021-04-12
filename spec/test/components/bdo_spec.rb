require 'rails_helper'

describe 'Bdo component', type: :feature, js: true do
  include Utils

  it 'Renders a simple and enhanced bdo tag on a page' do
    matestack_render do
      # Simple bdo
      bdo dir: 'ltr', text: 'Simple bdo ltr tag'
      bdo dir: 'rtl', text: 'Simple bdo rtl tag'
      # Enhanced bdo
      bdo id: 'foo', class: 'bar', dir: 'ltr' do
        plain 'This text will go left-to-right.' # optional content
      end
      bdo id: 'bar', class: 'foo', dir: 'rtl' do
        plain 'This text will go right-to-left.' # optional content
      end
    end

    expect(page).to have_selector("bdo[dir='ltr']", text: 'Simple bdo ltr tag')
    expect(page).to have_selector("bdo[dir='rtl']", text: 'Simple bdo rtl tag')
    expect(page).to have_selector("bdo#foo.bar[dir='ltr']", text: 'This text will go left-to-right')
    expect(page).to have_selector("bdo#bar.foo[dir='rtl']", text: 'This text will go right-to-left')
  end
end
