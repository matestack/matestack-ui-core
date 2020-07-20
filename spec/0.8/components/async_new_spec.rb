require_relative "../../support/utils"
include Utils

# Temporary new home for async to get the new examples going
# Examples adapted from the original async_spec
describe Matestack::Ui::Core::Async::Async, type: :feature, js: true do

  it "Example 1 - Rerender on event on page-level" do
    class CoolAsync < described_class
      optional :id
      def response
        div id: id do
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end

      register_self_as(:my_async_component)
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        my_async_component rerender_on: "my_event", id: 'async-cool-async'
      end
    end

    visit "/example"
    save_screenshot
    element = page.find("#async-cool-async")
    before_content = element.text
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).to have_no_content(before_content)
    expect(page).to have_css("#async-cool-async")
  end

end
