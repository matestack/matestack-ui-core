require_relative "../../../support/utils"
include Utils

describe "Onclick Component", type: :feature, js: true do

  it "emits event" do
    class ExamplePage < Matestack::Ui::Page
      def response
        onclick emit: 'show_message' do
          button 'click me'
        end
        toggle show_on: 'show_message' do
          plain "some message"
        end
      end
    end

    visit "/example"
    expect(page).not_to have_content("some message")

    click_on 'click me'
    expect(page).to have_content("some message")
  end

  it "emits event with data" do
    class ExamplePage < Matestack::Ui::Page
      def response
        onclick emit: 'show_message', data: "some static data" do
          button 'click me'
        end
        toggle show_on: 'show_message' do
          plain "some message"
          br
          plain "{{event.data}}"
        end
      end
    end

    visit "/example"
    expect(page).not_to have_content("some message")

    click_on 'click me'
    expect(page).to have_content("some message")
    expect(page).to have_content("some static data")
  end
end
