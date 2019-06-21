require_relative "../../support/utils"
include Utils

describe "Plain Component", type: :feature, js: true do

  it "Example 1" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          plain "Hello World!"
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    Hello World!
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
