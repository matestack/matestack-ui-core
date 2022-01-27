require 'rails_vue_js_spec_helper'

describe "Cable Component - delete", type: :feature, js: true do
  include VueJsSpecUtils

  it 'should be possible to delete an element by id' do
    matestack_vue_js_render do
      cable id: 'delete-cable', delete_on: 'delete' do
        5.times do |n|
           paragraph id: "p#{n}", text: "Number: #{n}"
        end
      end
    end
    expect(page).to have_selector('#delete-cable')
    5.times do |n|
      expect(page).to have_selector("#delete-cable > p#p#{n}", text: "Number: #{n}")
    end

    page.execute_script('MatestackUiVueJs.eventHub.$emit("delete", { data: "p2" })')
    expect(page).not_to have_selector('#delete-cable > p#p2')
    5.times do |n|
      expect(page).to have_selector("#delete-cable > p#p#{n}", text: "Number: #{n}") unless n == 2
    end

    page.execute_script('MatestackUiVueJs.eventHub.$emit("delete", { data: "p4" })')
    expect(page).not_to have_selector('#delete-cable > p#p4')
    5.times do |n|
      expect(page).to have_selector("#delete-cable > p#p#{n}", text: "Number: #{n}") unless n == 2 || n == 4
    end
  end

  it 'should be possible to delete multiple elements by id' do
    matestack_vue_js_render do
      cable id: 'delete-cable', delete_on: 'delete' do
        5.times do |n|
           paragraph id: "p#{n}", text: "Number: #{n}"
        end
      end
    end
    expect(page).to have_selector('#delete-cable')
    5.times do |n|
      expect(page).to have_selector("#delete-cable > p#p#{n}", text: "Number: #{n}")
    end

    page.execute_script('MatestackUiVueJs.eventHub.$emit("delete", { data: ["p2", "p4"] })')
    expect(page).not_to have_selector('#delete-cable > p#p2')
    expect(page).not_to have_selector('#delete-cable > p#p4')
    5.times do |n|
      expect(page).to have_selector("#delete-cable > p#p#{n}", text: "Number: #{n}") unless n == 2 || n == 4
    end
  end

end
