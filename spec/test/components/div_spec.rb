require_relative "../support/utils"
include Utils

describe "Div Component", type: :feature, js: true do

  it "Example 1" do

    class ExamplePage < Matestack::Ui::Page
      def response
        #simple div
        div
        #simple div with attributes
        div id: "my-id", class: "my-class"
        #nested div
        div do
          div id: "my-nested-div"
        end
      end
    end

    visit "/example"

    static_output = page.html
    expected_static_output = <<~HTML
      <div></div>
      <div id="my-id" class="my-class"></div>
      <div>
        <div id="my-nested-div"></div>
      </div>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
