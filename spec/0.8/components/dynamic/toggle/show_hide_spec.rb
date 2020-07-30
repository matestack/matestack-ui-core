require_relative "../../../../support/utils"
include Utils

describe "Toggle Component", type: :feature, js: true do

  it "show on event" do
    class ExamplePage < Matestack::Ui::Page
      def response
        toggle show_on: "my_event", id: 'toggle-div' do
          div id: "my-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
        toggle show_on: "multi_event_1, multi_event_2", id: 'toggle-second-div' do
          div id: "my-second-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    visit "/example"
    expect(page).not_to have_selector "#my-div"
    expect(page).not_to have_selector "#my-second-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).to have_selector "#my-div"
    expect(page).not_to have_selector "#my-second-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_2")')
    expect(page).to have_selector "#my-div"
    expect(page).to have_selector "#my-second-div"

    visit "/example"
    expect(page).not_to have_selector "#my-second-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_1")')
    expect(page).to have_selector "#my-second-div"
  end

  it "hide on event" do
    class ExamplePage < Matestack::Ui::Page
      def response
        toggle hide_on: "my_event", id: 'toggle-div' do
          div id: "my-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
        toggle hide_on: "multi_event_1, multi_event_2", id: 'toggle-second-div' do
          div id: "my-second-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    visit "/example"
    expect(page).to have_selector "#my-div"
    expect(page).to have_selector "#my-second-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).not_to have_selector "#my-div"
    expect(page).to have_selector "#my-second-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_2")')
    expect(page).not_to have_selector "#my-div"
    expect(page).not_to have_selector "#my-second-div"

    visit "/example"
    expect(page).to have_selector "#my-second-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_1")')
    expect(page).not_to have_selector "#my-second-div"
  end

  it "show on / hide on combination init not shown by default" do
    class ExamplePage < Matestack::Ui::Page
      def response
        toggle show_on: "my_show_event", hide_on: "my_hide_event", id: 'toggle-div' do
          div id: "my-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    visit "/example"
    expect(page).not_to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_show_event")')
    expect(page).to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_hide_event")')
    expect(page).not_to have_selector "#my-div"
  end

  it "show on / hide on combination init shown if configured" do
    class ExamplePage < Matestack::Ui::Page
      def response
        toggle show_on: "my_show_event", hide_on: "my_hide_event", init_show: true, id: 'toggle-div' do
          div id: "my-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    visit "/example"
    expect(page).to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_hide_event")')
    expect(page).not_to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_show_event")')
    expect(page).to have_selector "#my-div"
  end

  it "hide after show on event" do
    class ExamplePage < Matestack::Ui::Page
      def response
        toggle show_on: "my_event", hide_after: 1000, id: 'toggle-div' do
          div id: "my-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    visit "/example"
    expect(page).not_to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).to have_selector "#my-div"

    sleep 1
    expect(page).not_to have_selector "#my-div"
  end

  it "show on event with event payload" do
    class ExamplePage < Matestack::Ui::Page
      def response
        toggle show_on: "my_event", id: 'toggle-div' do
          div id: "my-div" do
            plain "{{event.data.message}}"
          end
        end
      end
    end

    visit "/example"
    expect(page).not_to have_content "test!"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event", { message: "test!" })')
    expect(page).to have_content "test!"
  end

end
