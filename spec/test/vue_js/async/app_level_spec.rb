require 'rails_vue_js_spec_helper'

describe "Async Component", type: :feature, js: true do
  include VueJsSpecUtils

  it 'works on page level' do
    matestack_vue_js_render do
      async id: 'async', rerender_on: 'update' do
        plain 'Time now: '
        paragraph text: DateTime.now.strftime("%Q")
      end
    end
    expect(page).to have_content('Time now:')
    initial_timestamp = page.find("p").text # initial page load
    page.execute_script('MatestackUiVueJs.eventHub.$emit("update")')
    expect(page).to have_content('Time now:')
    expect(page).not_to have_content(initial_timestamp)
  end

  it 'should work on app level' do
    matestack_vue_js_layout do
      async id: 'async', rerender_on: 'update' do
        plain 'Time now: '
        paragraph text: DateTime.now.strftime("%Q")
      end
    end
    matestack_vue_js_render reset_app: false do
      plain 'A page inside the app'
    end

    expect(page).to have_content('A page inside the app')
    expect(page).to have_content('Time now:')
    initial_timestamp = page.find("p").text # initial page load
    page.execute_script('MatestackUiVueJs.eventHub.$emit("update")')
    expect(page).to have_content('Time now:')
    expect(page).not_to have_content(initial_timestamp)
    reset_matestack_vue_js_layout
  end

end
