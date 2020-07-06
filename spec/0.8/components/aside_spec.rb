require_relative "../../support/utils"
include Utils

describe "Aside Component", type: :feature, js: true do
  it "Example 1" do
    class ExamplePage < Matestack::Ui::Page
      def response
        #simple aside
        aside
        #simple aside with attributes
        aside id: "my-id", class: "my-class"
        #nested aside
        aside do
          paragraph text: "This is some text"
        end
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
      <aside></aside>
      <aside id="my-id" class="my-class"></aside>
      <aside>
        <p>This is some text</p>
      </aside>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end


