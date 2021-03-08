require 'rails_helper'

describe "Cable Component", type: :feature, js: true do
  include Utils
  # include Matestack::Ui::Core::Helper

  before :each do

  end

  it 'should have the typical matestack wrapping classes' do
    matestack_render do
      cable id: 'foobar' do
        plain 'cable'
      end
    end
    container = '.matestack-cable-component-container'
    wrapper = '.matestack-cable-component-wrapper'
    expect(page).to have_selector("#{container}")
    expect(page).to have_selector("#{container} > #{wrapper}")
    expect(page).to have_selector("#{container} > #{wrapper} > #foobar.matestack-cable-component-root", text: 'cable')
  end

  it 'should require an id' do
    matestack_render do
      cable
    end
    expect(page).to have_content('Required property id is missing for Matestack::Ui::Core::Cable::Cable')
  end

  it 'should work after a page transition' do
    matestack_render(reset_app: false, page: MatestackTransitionPage) do
      cable id: 'cable-replace', replace_on: 'replace' do
        paragraph id: 'id', text: 'Paragraph'
      end
    end
    matestack_render(reset_app: false) do
      transition path: :matestack_transition_test_path, text: 'Transition'
    end
    expect(page).to have_content('Transition')
    expect(page).not_to have_content('Paragraph')
    click_on 'Transition'
    expect(page).not_to have_content('Transition')
    expect(page).to have_selector('p#id', text: 'Paragraph')
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("replace", { data: "<h1 id=\"id\">replaced</h1>" })')
    expect(page).to have_selector('h1#id', text: 'replaced')
    reset_matestack_app
  end

  it 'should be possible to add vue.js components' do
    matestack_render do
      cable id: 'cable-replace', replace_on: 'replace' do
        paragraph text: 'paragraph', id: 'id'
      end
      toggle show_on: 'test' do
        plain 'event successful emitted'
      end
    end
    expect(page).to have_selector('p#id', text: 'paragraph')
    expect(page).not_to have_selector('button', text: 'Click')
    expect(page).not_to have_content('event successful emitted')
    # onclick = matestack_component(:heading, text: 'test')
    onclick = matestack_component(:onclick, emit: :test) { button text: 'Click' }
    script = "MatestackUiCore.matestackEventHub.$emit('replace', { data: \"#{onclick}\" })".gsub("\n", "")
    page.execute_script(script)
    expect(page).not_to have_selector('p#id', text: 'paragraph')
    expect(page).to have_selector('button', text: 'Click')
    expect(page).not_to have_content('event successful emitted')

    click_on 'Click'
    expect(page).to have_content('event successful emitted')
  end

  it 'should render Vue.js components and forms without Vue.js console error' do
    # unfortunately I can't test this as I'm not getting the browsers console.log via capybara/Selenium
    # tried all hints found on Stackoverflow etc
    matestack_render do
      cable id: 'cable-replace', replace_on: 'replace' do
        form for: :some_object, path: "/", method: :post do
          form_input key: :foo, type: :text, label: :foo, id: :foo
        end
      end
    end

    # this was throwing a console error in v.1.3.0
    # "Interpolation inside attributes has been removed. Use v-bind or the colon shorthand instead. For example, instead of <div id="{{ val }}">, use <div :id="val">."
    # fixed in v.1.3.1 without explicitly testing it...

    expect(page).to have_selector('form')
    expect(page).to have_selector('input#foo')
  end

  it 'should work without any initial body given' do
    matestack_render do
      cable id: 'cable-replace', replace_on: 'replace' do
        # nothing
      end
      toggle show_on: 'test' do
        plain 'event successful emitted'
      end
    end

    expect(page).not_to have_content('event successful emitted')

    onclick = matestack_component(:onclick, emit: :test) { button text: 'Click' }
    script = "MatestackUiCore.matestackEventHub.$emit('replace', { data: \"#{onclick}\" })".gsub("\n", "")
    page.execute_script(script)

    expect(page).to have_selector('button', text: 'Click')
    expect(page).not_to have_content('event successful emitted')

    click_on 'Click'
    expect(page).to have_content('event successful emitted')
  end

end
