require 'rails_vue_js_spec_helper'

describe "Cable Component - replace", type: :feature, js: true do
  include VueJsSpecUtils

  it 'should be possible to replace the cable content with an element' do
    matestack_vue_js_render do
      cable id: 'replace-cable', replace_on: 'replace' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#replace-cable')
    expect(page).to have_selector('#replace-cable > p', text: 'foobar')

    page.execute_script('MatestackUiVueJs.eventHub.$emit("replace", { data: "<h1 id=\"h1\">replaced</h1>" })')
    expect(page).to have_selector('#replace-cable')
    expect(page).not_to have_selector('#replace-cable > p')
    expect(page).to have_selector('#replace-cable > h1#h1', text: 'replaced')
  end

  it 'should be possible to replace the cable content with multiple elements' do
    matestack_vue_js_render do
      cable id: 'replace-cable', replace_on: 'replace' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#replace-cable')
    expect(page).to have_selector('#replace-cable > p', text: 'foobar')

    page.execute_script(
      'MatestackUiVueJs.eventHub.$emit("replace", { data: ["<h1 id=\"h1\">replaced</h1>", "<h2 id=\"h2\">another</h2>"] })'
    )
    expect(page).to have_selector('#replace-cable')
    expect(page).not_to have_selector('#replace-cable > p')
    expect(page).to have_selector('#replace-cable > h1#h1', text: 'replaced')
    expect(page).to have_selector('#replace-cable > h1#h1 + h2#h2', text: 'another')
  end

end
