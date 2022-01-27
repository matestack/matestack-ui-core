require 'rails_vue_js_spec_helper'

describe "Cable Component - update", type: :feature, js: true do
  include VueJsSpecUtils

  it 'should be possible to update an element with matching id' do
    matestack_vue_js_render do
      cable id: 'update-cable', update_on: 'update' do
        5.times do |n|
          paragraph id: "p#{n}", text: "Number: #{n}"
       end
      end
    end
    expect(page).to have_selector('#update-cable')
    5.times do |n|
      expect(page).to have_selector("#update-cable > p#p#{n}", text: "Number: #{n}")
    end

    page.execute_script('MatestackUiVueJs.eventHub.$emit("update", { data: "<h1 id=\"p2\">updated</h1>" })')
    expect(page).not_to have_selector('#update-cable > p#p2')
    expect(page).to have_selector('#update-cable > h1#p2', text: 'updated')
    5.times do |n|
      expect(page).to have_selector("#update-cable > p#p#{n}", text: "Number: #{n}") unless n == 2
    end
  end

  it 'should be possible to append multiple elements' do
    matestack_vue_js_render do
      cable id: 'update-cable', update_on: 'update' do
        5.times do |n|
          paragraph id: "p#{n}", text: "Number: #{n}"
       end
      end
    end
    expect(page).to have_selector('#update-cable')
    5.times do |n|
      expect(page).to have_selector("#update-cable > p#p#{n}", text: "Number: #{n}")
    end

    page.execute_script(
      'MatestackUiVueJs.eventHub.$emit("update", { data: ["<h1 id=\"p2\">updated</h1>", "<h2 id=\"p4\">another</h2>"] })'
    )
    expect(page).not_to have_selector('#update-cable > p#p2')
    expect(page).not_to have_selector('#update-cable > p#p4')
    expect(page).to have_selector('#update-cable > h1#p2', text: 'updated')
    expect(page).to have_selector('#update-cable > h2#p4', text: 'another')
    5.times do |n|
      expect(page).to have_selector("#update-cable > p#p#{n}", text: "Number: #{n}") unless n == 2 || n == 4
    end
  end

end
