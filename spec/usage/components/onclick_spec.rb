require_relative "../../support/utils"
include Utils

describe "Nav Component", type: :feature, js: true do

  it "Example 1" do
    class ExamplePage < Matestack::Ui::Page
      def response
        components {
          async show_on: 'show_message' do
            div id: 'the_message' do
              plain "{{event.data.message}}"
            end
          end
          onclick click_function do
            div id: 'click_this' do
              plain "Click me"
            end
          end
        }
      end

      def click_function
        return {
          emit: 'show_message',
          data: {
            message: "This is a cool message"
          }
        }
      end
    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div><div id="click_this">Click me</div></div>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
    find('div', id: 'click_this').click

    new_expected_static_output = <<~HTML
    <div id="the_message">This is a cool message</div>
    <div>Click me!</div>
    HTML
  end

end
