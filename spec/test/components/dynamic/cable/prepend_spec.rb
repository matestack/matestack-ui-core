require 'rails_helper'

describe "Cable Component - prepend", type: :feature, js: true do
  include Utils

  it 'should be possible to prepend an element' do
    matestack_render do
      cable id: 'prepend-cable', prepend_on: 'prepend' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#prepend-cable')
    expect(page).to have_selector('#prepend-cable > p', text: 'foobar')
    page.execute_script('MatestackUiCore.eventHub.$emit("prepend", { data: "<h1 id=\"h1\">Prepended</h1>" })')
    expect(page).to have_selector('#prepend-cable')
    expect(page).to have_selector('#prepend-cable > h1#h1', text: 'Prepended')
    expect(page).to have_selector('#prepend-cable > h1#h1 + p', text: 'foobar')
  end

  it 'should be possible to prepend multiple elements' do
    matestack_render do
      cable id: 'prepend-cable', prepend_on: 'prepend' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#prepend-cable')
    expect(page).to have_selector('#prepend-cable > p', text: 'foobar')
    page.execute_script(
      'MatestackUiCore.eventHub.$emit("prepend", { data: ["<h1 id=\"h1\">Prepended</h1>", "<h2 id=\"h2\">another</h2>"] })'
    )
    expect(page).to have_selector('#prepend-cable')
    expect(page).to have_selector('#prepend-cable > h1#h1', text: 'Prepended')
    expect(page).to have_selector('#prepend-cable > h1#h1 + h2#h2', text: 'another')
    expect(page).to have_selector('#prepend-cable > h1#h1 + h2#h2 + p', text: 'foobar')
  end

end
