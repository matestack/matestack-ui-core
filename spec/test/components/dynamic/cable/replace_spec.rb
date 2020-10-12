require 'rails_helper'

describe "Cable Component - replace", type: :feature, js: true do
  include Utils

  it 'should be possible to replace the cable content with an element' do
    matestack_render do
      cable id: 'replace-cable', replace_on: 'replace' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#replace-cable')
    expect(page).to have_selector('#replace-cable > p', text: 'foobar')

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("replace", { data: "<h1 id=\"h1\">replaced</h1>" })')
    expect(page).to have_selector('#replace-cable')
    expect(page).not_to have_selector('#replace-cable > p')
    expect(page).to have_selector('#replace-cable > h1#h1', text: 'replaced')
  end

  it 'should be possible to replace the cable content with multiple elements' do
    matestack_render do
      cable id: 'replace-cable', replace_on: 'replace' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#replace-cable')
    expect(page).to have_selector('#replace-cable > p', text: 'foobar')

    page.execute_script(
      'MatestackUiCore.matestackEventHub.$emit("replace", { data: ["<h1 id=\"h1\">replaced</h1>", "<h2 id=\"h2\">another</h2>"] })'
    )
    expect(page).to have_selector('#replace-cable')
    expect(page).not_to have_selector('#replace-cable > p')
    expect(page).to have_selector('#replace-cable > h1#h1', text: 'replaced')
    expect(page).to have_selector('#replace-cable > h1#h1 + h2#h2', text: 'another')
  end

end
