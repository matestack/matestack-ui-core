require 'rails_helper'

describe "Cable Component - append", type: :feature, js: true do
  include Utils

  it 'should be possible to append an element' do
    matestack_render do
      cable id: 'append-cable', append_on: 'append' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#append-cable')
    expect(page).to have_selector('#append-cable > p', text: 'foobar')
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("append", { data: "<h1 id=\"h1\">Appended</h1>" })')
    expect(page).to have_selector('#append-cable')
    expect(page).to have_selector('#append-cable > p', text: 'foobar')
    expect(page).to have_selector('#append-cable > p + h1#h1', text: 'Appended')
  end

  it 'should be possible to append multiple elements' do
    matestack_render do
      cable id: 'append-cable', append_on: 'append' do
        paragraph text: 'foobar'  
      end
    end
    expect(page).to have_selector('#append-cable')
    expect(page).to have_selector('#append-cable > p', text: 'foobar')
    page.execute_script(
      'MatestackUiCore.matestackEventHub.$emit("append", { data: ["<h1 id=\"h1\">Appended</h1>", "<h2 id=\"h2\">another</h2>"] })'
    )
    expect(page).to have_selector('#append-cable')
    expect(page).to have_selector('#append-cable > p', text: 'foobar')
    expect(page).to have_selector('#append-cable > p + h1#h1', text: 'Appended')
    expect(page).to have_selector('#append-cable > p + h1#h1 + h2#h2', text: 'another')
  end

end
