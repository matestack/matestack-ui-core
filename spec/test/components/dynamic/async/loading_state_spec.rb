require_relative "../../../support/utils"
include Utils

describe "Async Component", type: :feature, js: true do

  it "has 'loading' css class when rerendering" do

    class ExamplePage < Matestack::Ui::Page
      def response
        async rerender_on: "my_event", id: 'async-div' do
          sleep 2 # mock hard work
          div id: "my-div" do
            plain DateTime.now.to_i
          end
        end
      end
    end

    visit "/example"

    expect(page).to have_css '.matestack-async-component-container .matestack-async-component-wrapper', visible: :all

    page.execute_script('MatestackUiCore.eventHub.$emit("my_event")')

    expect(page).to have_css '.matestack-async-component-container.loading .matestack-async-component-wrapper.loading', visible: :all

    sleep 1

    expect(page).to have_css '.matestack-async-component-container .matestack-async-component-wrapper', visible: :all
    expect(page).not_to have_css '.matestack-async-component-container.loading .matestack-async-component-wrapper.loading', visible: :all

  end

  it "has 'loading' css class when deferring" do

    class ExamplePage < Matestack::Ui::Page
      def response
        async defer: 1000, id: 'async-div' do
          div id: "my-div" do
            plain DateTime.now.to_i
          end
        end
      end
    end

    visit "/example"

    expect(page).to have_css '.matestack-async-component-container.loading .matestack-async-component-wrapper.loading', visible: :all
    sleep 1
    expect(page).to have_css '.matestack-async-component-container .matestack-async-component-wrapper', visible: :all
    expect(page).not_to have_css '.matestack-async-component-container.loading .matestack-async-component-wrapper.loading', visible: :all

  end

end
